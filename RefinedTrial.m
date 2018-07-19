classdef RefinedTrial < handle

	properties ( GetAccess = public, SetAccess = public )
		trialIndex;			% trial index within the block
		type;				% trial type, see TRIAL_TYPE_DEF for available values
		fp;
		rf;
		rf2;
		cue;
		cue2;
		jmp1;
		jmp2;
		vf1;
		vf2;
		hasBPC;				% whether this trial has badphotocell codes
		a2dRate;			% analog to digital sampling rate for eye trace
		eyeTrace;			% structure containing field "x" for horizontal eye trace and "y" for vertical eye trace
		LFP;				% local field potential signal
		evnts;				% 2-row matrix with the second row for event codes and the first for corresponding time relative to trial start in milliseconds
		units;				% structure array, each element for one recorded unit:
							%	units.channel:	channel name (offline) or ID (online)
							%	units.index:	unit number ( for Alpha&Omega: 0 for level, 1~4 for unit 1~4 )
							%	units.spikes:	each column contains a series of sample points from a spike
							%	units.times:	a vector containing times of spikes; in ms
							%	units.samRate:	sampling rate for spikes
		saccades;			% a structure containing all saccades in this trial
		iResponse1;			% 1st response saccade index in the array saccades
		iResponse2;			% 2nd response saccade index in the array saccades
	end

	% properties (Constant)
	% 	MRDR_STRUCT		= uint8(1);
	% 	AO_STRUCT		= uint8(2);
	% 	REFINED_STRUCT	= uint8(4);	
	% end

	methods ( Static )
		function dataSrc = MRDR_STRUCT()
		% trial structure converted from Rex data with MRDR
			dataSrc = uint8(1);
		end
		function dataSrc = AO_STRUCT()
			% trial structure converted from Alpha&Omega data
			dataSrc = uint8(2);
		end
		function dataSrc = REFINED_STRUCT()
			% trial structure saved by class RefinedTrial
			dataSrc = uint8(4);
		end
	end

	methods

		function obj = RefinedTrial( data, dataSrc, calibration )
			%%	data:		a structure describing a trial
			%	dataSrc:	source of the data sturcture
			%				possible values:
			%					RefinedTrial.MRDR_STRUCT		data structure converted by using MRDR
			%					RefinedTrial.AO_STRUCT			data structure from data recorded by Alpha&Omega
			%					RefinedTrial.REFINED_STRUCT		data structure from an instance of RefinedTrial
			%   calibration: a cell array:
			%					1st element: calibration function handle
			%					2nd element: calibration map which is the 1st argument of the calibration function
			%					3rd element: true for forward calibration, vice versa
			%				By not giving this argument or giving it as empty, no change will be done.
			if( nargin() < 1 )
				data = [];
			end
			if( nargin() < 2 )
				dataSrc = RefinedTrial.REFINED_STRUCT;
			end
			if( nargin() < 3 )
				calibration = [];
			end

			switch( dataSrc )
				case RefinedTrial.MRDR_STRUCT
					% trialIndex
					obj.trialIndex = int32(data.trialNumber);
					
					% events: 1st row for time and 2nd row for codes
					obj.evnts(2,:) = uint16([data.Events(:).Code]);
					obj.evnts(1,:) = uint16([data.Events(:).Time]);
					
					% set hasBPC
					if( any( obj.evnts(2,:) == REX_CODE_MAP.BADPHOTOCELL ) )
						obj.hasBPC = true;
					else
						obj.hasBPC = false;
					end
					
					% set stimuli
					stims = REX_CODE_MAP.DECODE( obj.evnts );
					obj.fp		= stims{REX_CODE_MAP.FP};
					obj.jmp1	= stims{REX_CODE_MAP.JMP1};
					obj.jmp2	= stims{REX_CODE_MAP.JMP2};
					obj.rf		= stims{REX_CODE_MAP.RF};
					obj.rf2		= stims{REX_CODE_MAP.RF2};
					obj.cue		= stims{REX_CODE_MAP.CUE};
					obj.cue2	= stims{REX_CODE_MAP.CUE2};
					obj.vf1		= stims{REX_CODE_MAP.VF1};
					obj.vf2		= stims{REX_CODE_MAP.VF2};
					clear stims;

					% set type
					if( any( obj.evnts(2,:) == REX_CODE_MAP.ABORT ) )
						obj.type = TRIAL_TYPE_DEF.ABORT;
					elseif( any( obj.evnts(2,:) == REX_CODE_MAP.FIXBREAK ) )
						obj.type = TRIAL_TYPE_DEF.FIXBREAK;
					elseif( any( obj.evnts(2,:) == REX_CODE_MAP.ERROR ) )
						obj.type = TRIAL_TYPE_DEF.ERROR;						
					elseif( any( obj.evnts(2,:) == REX_CODE_MAP.REWARD ) )
						obj.type = TRIAL_TYPE_DEF.CORRECT;
					else
						obj.type = TRIAL_TYPE_DEF.UNKNOWN;
						return;
					end
					if size( obj.fp, 2 ) > 1 || size( obj.fp.x, 2 ) > 1 || size( obj.fp.y, 2 ) > 1 || size( obj.jmp1, 2 ) > 1 || size( obj.jmp1.x, 2 ) > 1 || size( obj.jmp1.y, 2 ) > 1 || isempty(data.Signals )...
						|| obj.evnts(1,end) / 1000 * MK_CONSTANTS.TIME_UNIT > MK_CONSTANTS.TRIAL_DUR_MAX	% trial too long
						obj.type = TRIAL_TYPE_DEF.UNKNOWN;
						return ;
					end

					% set analog signals
					% obj.a2dRate = MK_CONSTANTS.A2DRATE;
					obj.a2dRate = data.a2dRate;
					for i = 1 : size( data.Signals, 2 )
						switch data.Signals(1,i).Name
							case SIG_NAME_DEF.HORIZONTAL_EYE
								x = i;
							case SIG_NAME_DEF.VERTICAL_EYE
								y = i;
							case SIG_NAME_DEF.LOCAL_FIELD_POTENTIAL
								obj.LFP = single( data.Signals(1,i).Signal );
								data.Signals(1,i).Signal = [];
								if( isempty(obj.LFP) )
									continue;
								end
								convStep = max( 0.005 * obj.a2dRate, 1 );
								convFunctor = ones(1,convStep)./convStep;
								for k = 1 : 50
									obj.LFP = single( conv( obj.LFP, convFunctor, 'same' ) ); % 'same' to get the central part
								end
						end
					end
					nDots = max( size( data.Signals(1,x).Signal, 2 ), size( data.Signals(1,y).Signal, 2 ) );
					obj.eyeTrace.x = single( data.Signals(1,x).Signal );
					obj.eyeTrace.y = single( data.Signals(1,y).Signal );
					if( ~isempty(calibration) && calibration{3} )	% forward calibration
						handle = calibration{1};
						[ obj.eyeTrace.x, obj.eyeTrace.y ] = handle( calibration{2:3}, double(obj.eyeTrace.x), double(obj.eyeTrace.y) );
					end
					data.Signals(1,x).Signal = [];
					data.Signals(1,y).Signal = [];

					% set recorded units
					for( i = size(data.Units,2) : -1 : 1 )
						obj.units(i).channel	= 0;
						obj.units(i).index		= data.Units(i).Code;
						obj.units(i).spikes		= ones(size(data.Units(i).Times));
						obj.units(i).times		= data.Units(i).Times;
						obj.units(i).samRate	= data.a2dRate
					end

					% set saccades
					if( ~isempty(obj.eyeTrace.x) && ~isempty(obj.eyeTrace.y) )
						obj.saccades = SaccadeTool.GetSacs( [ obj.eyeTrace.x; obj.eyeTrace.y ], obj.a2dRate, false );
					end

					% set iResponse1 and iResponse2
					fields = { 'jmp1', 'jmp2', 'iResponse1', 'iResponse2' };
					% ampmin = [ MK_CONSTANTS.RESPONSE_AMPLITUDE_MIN1, MK_CONSTANTS.RESPONSE_AMPLITUDE_MIN2 ];
					ampmin = [ norm( [ obj.jmp1.x, obj.jmp1.y ] ), norm( [ obj.jmp2.x, obj.jmp2.y ] ) ] / 2;
					latwin = [ MK_CONSTANTS.RESPONSE_BEFORE_JMP1,    MK_CONSTANTS.RESPONSE_BEFORE_JMP2 ];
					for( i = 1:2 )
						if( obj.(fields{i}).tOn > 0 && obj.(fields{i}).nPats <= 1 && ~isempty(obj.saccades) )
							obj.(fields{i+2}) =...
								find( [obj.saccades.latency] > obj.(fields{i}).tOn - latwin(i) &...
									  [obj.saccades.amplitude] > ampmin(i), 1, 'first' );
						end
					end

				case RefinedTrial.AO_STRUCT
					;

				case RefinedTrial.REFINED_STRUCT
					% If a field is not given, then its value will be empty;
					% it is the same effect as giving this field with the empty value.
					fields = fieldnames(obj);
					for( field = fields' )
						if( isfield( data, field{1} ) )
							obj.( field{1} ) = data.( field{1} );
						else
							obj.( field{1} ) = [];
						end
					end

				otherwise
					error(sprintf([
						'Usage: obj = RefinedTrial( data [, dataSrc = RefinedTrial.MRDR_STRUCT ] )\n'...
						'\tInvalid dataSrc value: %d\n'...
						'\tPossible dataSrc values:\n'...
						'\t\tRefinedTrial.MRDR_STRUCT(%d)\n'...
						'\t\tRefinedTrial.AO_STRUCT(%d)\n'...
						'\t\tRefinedTrial.REFINED_STRUCT(%d)\n'], dataSrc,...
						RefinedTrial.MRDR_STRUCT, RefinedTrial.AO_STRUCT, RefinedTrial.REFINED_STRUCT ) );
			end
		end

		function data = GetData( obj )
			fields = fieldnames(obj);
			for( field = fields' )
				data.( field{1} ) = obj.( field{1} );
			end
		end

		function SetData( obj, data )
			% To set a member empty, an empty field must be given in the structure data.
			fields = fieldnames(obj);
			for( field = fields' )
				if( isfield( data, field{1} ) )
					obj.( field{1} ) = data.( field{1} );
				end
			end
		end

		function [ tBreak, breakSac ] = GetBreak( obj, acd2Code )
			if( nargin() == 1 )
				acd2Code = false;	% false means tBreak not according to code but saccade initiation
			end
			tBreak = -1*MK_CONSTANTS.TIME_UNIT;
			breakSac = SaccadeTool.Saccade();
			for( i = size(obj,2) : -1 : 1 )
				tBreak(i) = -1 * MK_CONSTANTS.TIME_UNIT;
				breakSac(i) = SaccadeTool.Saccade();
				if( isempty( obj(i).evnts ) || isempty( obj(i).saccades ) )
					%fprintf( 'Trial Index: %d\n\tNo events data!\n', obj(i).trialIndex );
					continue;
				end
				t = obj(i).evnts( 1, obj(i).evnts(2,:) == REX_CODE_MAP.FIXBREAK ) / 1000 * MK_CONSTANTS.TIME_UNIT;
				if( size(t,2) ~= 1 )
					%fprintf( 'Trial Index: %d\n\tMore than one break codes found!\n', obj(i).trialIndex );
					continue;
				else
					sac = obj(i).saccades(...
						[obj(i).saccades.latency] < t + 0.05 * MK_CONSTANTS.TIME_UNIT &...
						[obj(i).saccades.latency] > t - 0.1 * MK_CONSTANTS.TIME_UNIT );
					if( size(sac,2) ~= 1 )
						%fprintf( 'Trial Index: %d\n\t%d break saccades found!\n', obj(i).trialIndex, size(breakSac,2) );
						continue;
					end
					breakSac(i) = sac;
					if( acd2Code )
						tBreak(i) = t;
					else
						tBreak(i) = sac.latency;
					end
				end
			end
		end

		function SacCalibration( obj )
			if isempty( obj.saccades ) || strcmp( obj.type, TRIAL_TYPE_DEF.CORRECT ) ~= 1 || isempty( find( obj.eventCodes(2,:) == REX_CODE_MAP.JMP1ON, 1 ) ) || obj.jmp1.nPats == 0
				return;
			end
			
			j1Angle = cart2pol( obj.jmp1.x, obj.jmp1.y );
			j1Angle = j1Angle / pi * 180;
			iAroundJmp1 = find( [ obj.saccades(:).latency ] > obj.jmp1.tOn - 0.2, 1, 'first' );
			if isempty( iAroundJmp1 )
				obj.type = TRIAL_TYPE_DEF.ABNORMAL;
				return;
			end
			index = [ obj.saccades(:).amplitude ] == max( [ obj.saccades( iAroundJmp1 : end ).amplitude ] );
			for i = 1 : size( obj.saccades, 2 )
				obj.saccades(i).angle = obj.saccades(i).angle - obj.saccades(index).angle + j1Angle;
				if obj.saccades(i).angle < -179
					obj.saccades(i).angle = obj.saccades(i).angle + 360;
				end
				if obj.saccades(i).angle > 180
					obj.saccades(i).angle = obj.saccades(i).angle - 360;
				end
			end
		end

		function ShowParadigm( obj, newFigure )
			stimuli = [ obj.fp, obj.rf, obj.rf2, obj.cue, obj.cue2, obj.vf1, obj.vf2, obj.jmp1 ];	% store all stimuli in the structure array stimuli
			names = { 'fp', 'rf', 'rf2', 'cue','cue2', 'jmp1', 'vf1', 'vf2' };	% store all stimuli names in the cell array names

			t = [ stimuli.tOn, stimuli.tOff ];

			t = unique( t );	% remove redundant time points and sort them ascendingly
			t( t <= 0 ) = [];	% remove non-happened time points
			n = size(t,2);		% get the number of unique time points

			radius = 1;			% radius to draw a square stimulus
			if( newFigure )
				set( figure, 'NumberTitle', 'off', 'Name', [ 'trial number: ', num2str(obj.trialIndex), ' (', obj.type, ')' ] );	% open a new figure
			else
				set( gcf, 'NumberTitle', 'off', 'Name', [ 'trial number: ', num2str(obj.trialIndex), ' (', obj.type, ')' ] );	% open a new figure
			end

			for( i = 1 : n )		% for each time point t(i)
				subplot( round(sqrt(n/2)), ceil( n / round(sqrt(n/2)) ), i );	% designate a subplot; nX2n
				axis('equal');			% set the axies to the same scale
				set( gca, 'xlim', [-40,40], 'ylim', [-40,40], 'xtick', [], 'ytick', [] );	% set current axis
				rectangle( 'position', [-40,-40,80,80], 'facecolor', [0 0 0] );				% draw the black background
				
				% whether fp is on
				if( obj.fp.tOn > 0 && t(i) >= obj.fp.tOn && ( obj.fp.tOff <= 0 || t(i) < obj.fp.tOff ) )
					if( obj.fp.nPats == 1 )
						x = obj.fp.x(1);
						y = obj.fp.y(1);
					else
						x = 0;
						y = 0;
					end
					rectangle( 'position', [ x - 1.2*radius, y - 1.2*radius, 2 * radius + radius/5*2, 2 * radius + radius/5*2 ], 'edgecolor', [1,1,1] );
				end

				for( j = 1 : size(stimuli,2) - 1 )	% for each stimulus except for fp and jmp1
					if(stimuli(j).tOn > 0 && stimuli(j).tOn <= t(i) && ( t(i) < stimuli(j).tOff || stimuli(j).tOff <= 0 ) )
						for( k = 1 : stimuli(j).nPats )
							rectangle( 'position', [ stimuli(j).x(k) - radius, stimuli(j).y(k) - radius, 2 * radius, 2 * radius ],...
								'facecolor', [ stimuli(j).red(k), stimuli(j).green(k), stimuli(j).blue(k) ]/255 );
						end
					end
				end

				% whether jmp1 is on
				if( obj.jmp1.tOn > 0 && t(i) >= obj.jmp1.tOn && ( obj.jmp1.tOff <= 0 || t(i) < obj.jmp1.tOff ) )
					rectangle( 'position', [ obj.jmp1.x(1) - 1.2*radius, obj.jmp1.y(1) - 1.2*radius, 2 * radius, 2 * radius ], 'edgecolor', [1,1,0] );
				end

				% get the title of the subfigure
				subtitle = [ num2str( ( t(i) - t(1) ) * 1000 ), '  ' ];		% start the subtitle with the time point in ms
				for( j = 1 : size(names,2) )
					for( k = 1 : size( obj.(names{j}), 2 ) )
						if( t(i) == obj.(names{j})(k).tOn )
							subtitle = [ subtitle, names{j}, ' on;  ' ];
						end
						if( t(i) == obj.(names{j})(k).tOff )
							subtitle = [ subtitle, names{j}, ' off;  ' ];
						end
					end
				end
				title( subtitle );	% set the title of the current subfigure
			end
		end

		function PlotEyeTrace(obj, newFigure)
			if( nargin() == 1 )
				newFigure = true;
			elseif( nargin() ~= 2 )
				error('Usage: obj.PlotEyeTrace( [newFigure=true] )');
			end

			if( isempty(obj.eyeTrace) )
				disp( 'No eye trace data!' );
				return;
			end

			if newFigure
				figure;
			end
			hold on;

			%% draw eye trace
			if( ~isempty(obj.eyeTrace.x) && ~isempty(obj.eyeTrace.y) )
				hx = plot( ( 1:length(obj.eyeTrace.x) ) / obj.a2dRate * MK_CONSTANTS.TIME_UNIT, obj.eyeTrace.x, 'b', 'DisplayName', 'horizontal' );
				hy = plot( ( 1:length(obj.eyeTrace.y) ) / obj.a2dRate * MK_CONSTANTS.TIME_UNIT, obj.eyeTrace.y, 'g', 'DisplayName', 'vertical');
			end

			%% draw saccades edges
			y = get(gca,'ylim');
			for i = 1 : size( obj.saccades, 2 )
				text( double(obj.saccades(i).latency), y(1)+i*2, num2str(obj.saccades(i).angle) );
				plot( [1 1] * obj.saccades(i).latency, y, 'k:' );
				plot( [1 1] * ( obj.saccades(i).latency + obj.saccades(i).duration ), y, 'k:' );
				% if( i < obj.iResponse1 && obj.saccades(i).latency - obj.cue.tOn > 0.075 && obj.saccades(i).angle > 0 )
				% 	plot( [1 1] * obj.saccades(i).latency, y, 'c' );
				% end
			end

			%% draw events lines
			stims = { obj.fp, obj.cue, obj.cue2, obj.jmp1, obj.jmp2, obj.rf, obj.rf2, obj.vf1, obj.vf2 };
			txt   = { 'fo', 'ff', 'c1o', 'c1f', 'c2o', 'c2f', 'j1o', 'j1f', 'j2o', 'j2f', 'r1o', 'r1f', 'r2o', 'r2f', 'v1o', 'v1f', 'v2o', 'v2f' };
			colors = { 'k', 'g', 'c', 'r', 'm', 'b', 'y', [0 0.5 0], [0.5 0 0] };
			y = get(gca,'ylim');
			hstep = ( y(2) - y(1) ) / 4 / ( size(stims,2) - 1 );
			for( i = 1 : size(stims,2))
				for( stim = stims{i} )
					plot( [1 1] * stim.tOn, [ y(1), y(2)-hstep*(i-1) ], 'color', colors{i}, 'LineWidth', 1.25 );
					text( double(stim.tOn), y(2)-hstep*(i-1), txt{2*i-1}, 'VerticalAlignment', 'bottom' );
					plot( [1 1] * stim.tOff, [ y(1), y(2)-hstep*(i-1) ], 'color', colors{i}, 'LineWidth', 1.25 );
					text( double(stim.tOff), y(2)-hstep*(i-1), txt{2*i}, 'VerticalAlignment', 'bottom' );
				end
			end
			hold off;
		end

		function PlotLFP( obj, newFigure )
			if nargin == 1
				newFigure = true;
			elseif nargin ~= 2
				disp('Usage: obj.PlotEyeTrace( [ newFigure = true ] )');
				return;
			end

			if newFigure
				figure;
			end

			if( isempty(obj.LFP) )
				disp( 'No Local Field Potential data!' );
				return;
			end

			hold on;
			%% draw LFP
			plot( ( 1 : size( obj.LFP, 2 ) ) / obj.a2dRate * MK_CONSTANTS.TIME_UNIT, obj.LFP, 'b' );

			%% draw saccades edges
			y = get(gca,'ylim');
			hstep = ( y(2) - y(1) ) / ( size(obj.saccades,2) + 1 );
			for i = 1 : size( obj.saccades, 2 )
				text( double(obj.saccades(i).latency), y(1) + ( mod(i,2)/2 + 0.5 ) * hstep, num2str(obj.saccades(i).angle) );
				plot( [1 1] * obj.saccades(i).latency, y, 'k:' );
				plot( [1 1] * ( obj.saccades(i).latency + obj.saccades(i).duration ), y, 'k:' );
				if( i < obj.iResponse1 && obj.saccades(i).latency - obj.cue.tOn > 0.075 && obj.saccades(i).angle > 0 )
					plot( [1 1] * obj.saccades(i).latency, y, 'c' );
				end
			end

			%% draw events lines
			stims = { obj.fp, obj.cue, obj.cue2, obj.jmp1, obj.jmp2, obj.rf, obj.rf2 };
			txt   = { 'fo', 'ff', 'c1o', 'c1f', 'c2o', 'c2f', 'j1o', 'j1f', 'j2o', 'j2f', 'r1o', 'r1f', 'r2o', 'r2f' };
			colors = [ 'k', 'g', 'c', 'r', 'm', 'b', 'y' ];
			y = get(gca,'ylim');
			hstep = ( y(2) - y(1) ) / 4 / ( size(stims,2) - 1 );
			for( i = 1 : size(stims,2))
				for( stim = stims{i} )
					plot( [1 1] * stim.tOn, [ y(1), y(2)-hstep*(i-1) ], colors(i), 'LineWidth', 1.25 );
					text( double(stim.tOn), y(2)-hstep*(i-1), txt{2*i-1}, 'VerticalAlignment', 'bottom' );
					plot( [1 1] * stim.tOff, [ y(1), y(2)-hstep*(i-1) ], colors(i), 'LineWidth', 1.25 );
					text( double(stim.tOff), y(2)-hstep*(i-1), txt{2*i}, 'VerticalAlignment', 'bottom' );
				end
			end

			hold off;
		end

		function MainSequence( obj, properties, newFigure, dotByDot )
			if( nargin() < 1 )
				error( 'Usage: obj.MainSequence( [ properties = ''b.'', newFigure = true, dotByDot = true ] )' );
				return;
			end
			if( nargin() == 1 )
				properties = 'b.';
			end
			if( nargin() <= 2 )
				newFigure = true;
			end
			if( nargin() <= 3 )
				dotByDot = true;
			end
			if( newFigure )
				figure;
			end
			hold on;
			if( dotByDot )
				for( iSac = 1 : size(obj.saccades,2) )
					plot( log10( obj.saccades(iSac).amplitude ), log10( obj.saccades(iSac).peakSpeed ),...
						properties, 'tag', [ 'iSac: ', num2str(iSac) ] );
				end
			else
				if( ~isempty(obj.saccades) )
					plot( log10( [obj.saccades.amplitude] ), log10( [obj.saccades.peakSpeed] ),...
						properties, 'tag', [ 'trial index: ', num2str(obj.trialIndex) ] );
				end
			end
			hold off;
		end
		
	end
end