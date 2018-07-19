classdef RexBlock < handle
%% With this class, we can convert recorded raw data into generally arranged data for further analysis.
%  With its member functions, the design of the task can be briefly understood.

	properties ( SetAccess = public, GetAccess = public )
		blockName = [];
		trials = RefinedTrial([]);
		nTrials = uint32(0);
		nCorrect = uint32(0);
		nError = uint32(0);
		nFixbreak = uint32(0);
		nAbort = uint32(0);
		nUnknown = uint32(0);
		calibration = [];
	end

	properties ( SetAccess = protected, GetAccess = public )
		blockType = 'raw';
	end

	methods ( Static )
		function dataSrc = REX_RAW_FILE()
			dataSrc = uint8(1);
		end
		function dataSrc = MRDR_FILE()
			dataSrc = uint8(2);
		end
		function dataSrc = MRDR_STRUCT()
			dataSrc = uint8(4);
		end
		function dataSrc = AO_MPX_FILE()
			dataSrc = uint8(8);
		end
		function dataSrc = AO_MAT_FILE()
			dataSrc = uint8(16);
		end
		function dataSrc = AO_STRUCT()
			dataSrc = uint8(32);
		end
		function dataSrc = REFINED_FILE()
			dataSrc = uint8(64);
		end
		function dataSrc = REFINED_STRUCT()
			dataSrc = uint8(128);
		end
	end

	methods
		 %% RexBlock: obj = RexBlock( blockName, data [, dataSrc = RexBlock.REFINED_FILE, fieldsFlag = 0xFFFFFFFF ] )
		 %% blockName:	ignored when dataSrc is RexBlock.REFINED_FILE or RexBlock.REFINED_STRUCT
		 %  fieldsFlag:	specifing which fields to load; applicable only when dataSrc is RexBlock.REFINED_FILE
		 %  calibration: a cell array in which:
		 %					1st element is a flag which means performing calibration when true while recovering from a previous calibration when false
		 %					2nd element is a two-column array which defines set_points
		 %					3rd element is a two-column array which defines recorded_points
		 %				By not giving this argument or giving it as empty, no change will be done.
		 function obj = RexBlock( blockName, data, dataSrc, fieldsFlag, calibration )
			if( nargin() < 2 )
				if( exist('blockName','var') == 1 )
					obj.blockName = blockName;
				end
				obj.trials = [];
				return;
				%error( 'Usage: obj = RexBlock( blockName, data [, dataSrc = RexBlock.REFINED_FILE, fieldsFlag = 0 ] )' );
			end
			if( nargin() == 2 )
				dataSrc = RexBlock.REFINED_FILE;
			end
			if( nargin() <= 3 )
				fieldsFlag = bitor( DATA_FIELD_FLAG.SACCADES, DATA_FIELD_FLAG.RESPONSE_INDEX );
			end
			if( nargin() <= 4 )
				calibration = [];
			end

			if( isempty(data) )
				obj.trials = [];
				return;
			end

			switch( dataSrc )
				case RexBlock.REX_RAW_FILE
					try
						data( find( data ~= ' ', 1, 'last' ) + 1 : end ) = [];
						disp( [ 'Converting file: ', data, '...' ] );
						Trials = mrdr( '-s', '800', '-d', data );
						fprintf( '\tConverted to MRDR struct successfully!\n' );
						fprintf( '\tConverting to RexBlock...' );
						obj.FromMrdrStruct( blockName, Trials, calibration );
						fprintf( '\n\tConverted to RexBlock successfully!\n' );
						clear Trials;
					catch exception
						disp( [ 'Exeption thrown in RexBlock.m 86: ', exception.identifier ] );
						disp( [ 'Exception message: ', exception.message ] );
					end

				case RexBlock.MRDR_FILE
					try
						data( find( data ~= ' ', 1, 'last' ) + 1 : end ) = [];
						disp( [ 'Loading file: ', data ] );
						load( data );
						disp( 'File loaded successfully!' );
						if( exist('Trials') ~= 1 )
							obj.trials = [];
							error(sprintf( 'Invalid data file %s: no structure array Trials found!', data ) );
						end
						%obj = RexBlock( blockName, Trials, RexBlock.MRDR_STRUCT );
						obj.FromMrdrStruct( blockName, Trials, calibration );
						clear Trials;
					catch exception
						disp( [ 'Exeption thrown in RexBlock.m 77: ', exception.identifier ] );
						disp( [ 'Exception message: ', exception.message ] );
					end

				case RexBlock.MRDR_STRUCT
					obj.FromMrdrStruct( blockName, data, calibration );

				case RexBlock.AO_MAT_FILE
					% data.fileName						.mat file converted from .mpx file
					% data.EventCodeChann				channel for event codes. e.g., CInPort_003
					% data.EyeXChann					channel for horizontal eye signal. e.g., CAI_017
					% data.EyeYChann					channel for vertical eye signal. e.g., CAI_018
					% data.RecordChanns					channels for recordings. e.g., [ '010'; '017' ]

					try						
						fileName = ToolKit.RMEndSpaces( data.fileName );
						load(fileName);

						%% extract event codes
						EventCodes = eval( data.EventCodeChann );
						EventCodes(1,:) = EventCodes(1,:) / eval( [ data.EventCodeChann, '_KHz' ] );	% in ms

					
						%% extract eye signals
						Eye.X = double( eval( data.EyeXChann ) ) * double( eval( [ data.EyeXChann, '_Gain' ] ) ) / 10;
						Eye.Y = double( eval( data.EyeYChann ) ) * double( eval( [ data.EyeYChann, '_Gain' ] ) ) / 10;
						samRate.X = eval( [ data.EyeXChann, '_KHz' ] ) * 1000;
						samRate.Y = eval( [ data.EyeYChann, '_KHz' ] ) * 1000;
						a2dRate = min( [ samRate.X, samRate.Y ] );
						for( c = 'XY' )
							if( samRate.(c) > a2dRate )
								step = samRate.(c) / a2dRate;
								nDots = fix( size( Eye.(c), 2 ) / step );
								for i = 1 : nDots
									Eye.(c)(i) = mean( Eye.(c)( fix( (i-1)*step ) + 1 : fix( i*step ) ), 2 );
								end
								Eye.(c)( nDots+1 : size( Eye.(c), 2 ) ) = [];
								eval( [ eval(['data.Eye',c,'Chann']) '_TimeBegin' '=' eval(['data.Eye',c,'Chann']) '_TimeBegin' '+ 0.5/a2dRate;' ] );
							end
						end
						
						iStarts = find( EventCodes(2,:) == REX_CODE_MAP.START );
						nTrials = size(iStarts,2) - 1;

						for( i = nTrials : -1 : 1 )
							Trials(i).trialNumber = i;
							Trials(i).a2dRate = a2dRate;

							% eye signal sampling index relative to REX_CODE_MAP.START code time
							ixs = round( ( EventCodes( 1, iStarts(i) ) / 1000 - eval( [ data.EyeXChann, '_TimeBegin' ] ) ) * a2dRate ) + 1;		% start index
							ixe = round( ( EventCodes( 1, iStarts(i+1) ) / 1000 - eval( [ data.EyeXChann, '_TimeBegin' ] ) ) * a2dRate ) + 1;	% end index
							iys = round( ( EventCodes( 1, iStarts(i) ) / 1000 - eval( [ data.EyeYChann, '_TimeBegin' ] ) ) * a2dRate ) + 1;		% start index
							iye = round( ( EventCodes( 1, iStarts(i+1) ) / 1000 - eval( [ data.EyeYChann, '_TimeBegin' ] ) ) * a2dRate ) + 1;	% end index

							Trials(i).Signals(2).Signal = ones( 1, iye-iys+1 ) * NaN;
							Trials(i).Signals(2).Signal( max([2-iys,1]) : iye-iys+1 ) = Eye.Y( max([iys,1]) : iye );	% max() used in case iys <= 0, which means some early eye signals are missing
							Trials(i).Signals(1).Signal = ones( 1, ixe-ixs+1 ) * NaN;
							Trials(i).Signals(1).Signal( max([2-ixs,1]) : ixe-ixs+1 ) = Eye.X( max([ixs,1]) : ixe );	% max() used in case iys <= 0, which means some early eye signals are missing
							Trials(i).Signals(1).Name = 'horiz_eye';
							Trials(i).Signals(2).Name = 'vert_eye';
							for( j = iStarts(i+1)-1 : -1 : iStarts(i) )
								Trials(i).Events( j - iStarts(i) + 1 ).Code = EventCodes(2,j);
								Trials(i).Events( j - iStarts(i) + 1 ).Time = EventCodes(1,j) - EventCodes(1,iStarts(i));
							end
						end

						Trials(end).Units = [];
						obj.FromMrdrStruct( blockName, Trials, calibration );	% 1st trial in Trials will be discarded in this call,
																					% which results in that the 1st EventCode for obj.trials(i) is EventCodes(2,iStarts(i+1))

						%% extract recording data and store into trials
						if( isfield( data, 'RecordChanns' ) )	% for each channel recorded
							for( iChs = size( data.RecordChanns, 1 ) : -1 : 1 )
								for( iUnit = 4:-1:1 )	% template 1~4, unit 1~4
									index = (iChs-1)*5 + iUnit + 1;
									units(index).channel = data.RecordChanns(iChs,:);
									units(index).index = iUnit;
									units(index).samRate = eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_KHz' ] ) * 1000;
									if( exist( [ 'CSEG_', data.RecordChanns(iChs,:), '_Template', num2str(iUnit) ], 'var' ) )
										units(index).times	= ( double( eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_Template', num2str(iUnit) ] ) ) / units(index).samRate + eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_TimeBegin' ] ) ) * 1000;	% in ms
										units(index).spikes	= double( eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_Template', num2str(iUnit), '_SEG' ] ) );
									else
										units(index).times	= [];
										units(index).spikes	= [];
									end
								end

								% level, unit 0
								index = (iChs-1)*5 + 1;
								units(index).channel = data.RecordChanns(iChs,:);
								units(index).index = 0;
								units(index).samRate = units(2).samRate;
								units(index).times	= ( double( eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_LEVEL' ] ) ) / units(index).samRate + eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_TimeBegin' ] ) ) * 1000;	% in ms
								units(index).spikes	= double( eval( [ 'CSEG_', data.RecordChanns(iChs,:), '_LEVEL_SEG' ] ) );

								tLimit = [-200 250];	% time limit for spikes to save into one trial
								for( iUnit = 4 : -1 : 0 )									
									for( iTrial = 1 : obj.nTrials )
										index = (iChs-1)*5 + iUnit + 1;
										obj.trials(iTrial).units(index).channel = units(index).channel;
										obj.trials(iTrial).units(index).index = units(index).index;
										obj.trials(iTrial).units(index).samRate = units(index).samRate;
										iLogic = units(index).times >= EventCodes(1,iStarts(iTrial+1)) + tLimit(1) & units(index).times <= EventCodes(1,iStarts(iTrial+2)) + tLimit(2);
										obj.trials(iTrial).units(index).times = units(index).times(iLogic) - EventCodes(1,iStarts(iTrial+1));
										obj.trials(iTrial).units(index).spikes = units(index).spikes(:,iLogic);
									end
								end
							end
						end

					catch exception
						disp( [ 'Exeption thrown in RexBlock.m 145: ', exception.identifier ] );
						disp( [ 'Exception message: ', exception.message ] );
					end

				case RexBlock.AO_STRUCT
					;

				case RexBlock.REFINED_FILE
					blockName = [];
					try
						data( find( data ~= ' ', 1, 'last' ) + 1 : end ) = [];
						% load default fields
						disp( [ 'Loading file: ', data ] );
						load( data, 'blockName',...
							'trialIndex', 'type', 'fp', 'rf', 'rf2', 'cue', 'cue2', 'jmp1', 'jmp2', 'hasBPC', 'a2dRate',...
							'nTrials', 'nCorrect', 'nError', 'nFixbreak', 'nAbort', 'nUnknown' );

						% load user-defined fields
						marks = [ DATA_FIELD_FLAG.EYETRACE, DATA_FIELD_FLAG.LFP, DATA_FIELD_FLAG.EVENTS, DATA_FIELD_FLAG.SACCADES, DATA_FIELD_FLAG.RESPONSE_INDEX, DATA_FIELD_FLAG.RESPONSE_INDEX ];
						fields = { 'eyeTrace', 'LFP', 'evnts', 'saccades', 'iResponse1', 'iResponse2' };
						for( i = 1 : size( marks,2 ) )
							if( bitand( marks(i), fieldsFlag ) )
								load( data, fields{i} );
							end
						end
						disp( 'File loaded successfully!' );

						% construct data structure
						clear( 'data', 'dataSrc', 'fieldsFlag', 'marks', 'fields', 'i' );
						fields = who();
						for( field = fields' )
							if( ~strcmp( field{1}, 'obj' ) )
								data.(field{1}) = eval(field{1});
							end
						end

						% call another constructor
						%obj = RexBlock( [], data, RexBlock.REFINED_STRUCT );
						obj.FromRefinedStruct(data);

					catch exception
						disp( [ 'Exeption thrown in RexBlock.m 145: ', exception.identifier ] );
						disp( [ 'Exception message: ', exception.message ] );
					end

				case RexBlock.REFINED_STRUCT
					obj.FromRefinedStruct(data);

				otherwise
					error(sprintf([
						'Usage: obj = RexBlock( blockName, data [, dataSrc = RexBlock.REFINED_FILE, fieldsFlag = 0 ] )\n'...
						'\tInvalid dataSrc value: %d\n'...
						'\tPossible dataSrc values:\n'...
						'\t\tRexblock.REX_RAW_FILE(%d)\n'...
						'\t\tRexblock.MRDR_FILE(%d)\n'...						
						'\t\tRexblock.MRDR_STRUCT(%d)\n'...
						'\t\tRexblock.AO_MAT_FILE(%d)\n'...
						'\t\tRexblock.AO_STRUCT(%d)\n'...
						'\t\tRexblock.REFINED_FILE(%d)\n'...
						'\t\tRexblock.REFINED_STRUCT(%d)\n'], dataSrc,...
						RexBlock.REX_RAW_FILE, RexBlock.MRDR_FILE, RexBlock.MRDR_STRUCT, RexBlock.AO_MAT_FILE,...
						RexBlock.AO_STRUCT, RexBlock.REFINED_FILE, RexBlock.REFINED_STRUCT ) );
			end
		end

	end

	methods( Access = private )
		function FromMrdrStruct( obj, blockName, data, calibration )
			%% calibration: see the comments for RexBlock()
			
			if( nargin() == 4 && ~isempty(calibration) )
				obj.calibration.set_points = calibration{2};
				obj.calibration.recorded_points = calibration{3};
				if( calibration{1} )	% forward calibration
					calibration{2} = SaccadeTool.GetCalibrationMap( calibration{:} );		% calibration map
					calibration{1} = @SaccadeTool.Calibrate;	% calibration function handle
					calibration{3} = true;	% forward calibration
					calibration(4:end) = [];

					obj.calibration.function_name = 'SaccadeTool.Calibrate';
					obj.calibration.isCalibrated = true;
				else
					calibration = [];
					obj.calibration.function_name = [];
					obj.calibration.isCalibrated = false;
				end
			end

			obj.blockName = blockName;
			obj.nTrials = length(data) - 1;	% 1st trial discarded
			for( i = obj.nTrials : -1 : 1 )
				if( i == 491 )
					;
				end
				obj.trials(i) = RefinedTrial( data(i+1), RefinedTrial.MRDR_STRUCT, calibration );
				switch( obj.trials(i).type )
					case TRIAL_TYPE_DEF.CORRECT
						obj.nCorrect = obj.nCorrect + 1;
					case TRIAL_TYPE_DEF.ERROR
						obj.nError = obj.nError + 1;
					case TRIAL_TYPE_DEF.FIXBREAK
						obj.nFixbreak = obj.nFixbreak + 1;
					case TRIAL_TYPE_DEF.ABORT
						obj.nAbort = obj.nAbort + 1;
					case TRIAL_TYPE_DEF.UNKNOWN
						obj.nUnknown = obj.nUnknown + 1;
				end
			end
		end

		function FromRefinedStruct( obj, data )
			%% set block members
			fields = fieldnames(obj);
			for( field = fields' )
				if( ~strcmp( field{1}, 'trials' ) && isfield( data, field{1} ) )
					obj.(field{1}) = data.(field{1});
				end
			end

			%% set trials
			% get names of fields to set
			fields = fieldnames(obj.trials);
			iLogical =  false( size(fields) ) ;
			for( iField = 1 : length(fields) )
				if( ~isfield( data, fields{iField} ) )
					iLogical(iField) = true;
				end
			end
			fields(iLogical) = [];
			if( isempty(fields) )
				return;
			end
			
			% get the number of trials according to size of fields
			fineFlag = true;
			nTrials = obj.nTrials;
			for( iField = 1 : length(fields) )
				n = length( data.(fields{iField}) );
				if( nTrials > n )
					nTrials = n;
					fineFlag = false;
				elseif( nTrials < n )
					fineFlag = false;
				end
			end
			obj.nTrials = nTrials;
			if( ~fineFlag )
				warning( 'Number of trials inconsistent according to the size of each field!' );
			end

			% set fields of trials
			if( obj.nTrials == 0 )
				obj.trials.delete();
				obj.trials = [];
				return;
			end
			for( i = obj.nTrials : -1 : 1 )
				for( field = fields' )
					trial.(field{1}) = data.(field{1}){i};
				end
				obj.trials(i) = RefinedTrial( trial, RefinedTrial.REFINED_STRUCT );
			end
		end
	end

	methods

		function SaveData( obj, path, fileName )
			%% Usage: obj.SaveData( [ path = pwd(), fileName = blockName or randomized ] )
			
			if( nargin() == 1 || isempty(path) )
				path = [ pwd(), '/' ];
			end
			if( nargin() <= 2 || isempty(fileName) )
				if( isempty(obj.blockName) )
					fileName = char( randi(26,1,10) + 'a' - 1 );
				else
					fileName = [ obj.blockName, '.mat' ];
				end
			end
			if( path(end) ~= '/' && path(end) ~= '\' )
				path(end+1) = '/';
			end

			% set data from rexblock members
			block_fields = fieldnames(obj)';
			for( field = block_fields )
				if( ~strcmp( field{1}, 'trials' ) )
					data.(field{1}) = obj.(field{1});
				end
			end

			% set data from trials
			if( ~isempty(obj.trials) )
				trial_fields = fieldnames(obj.trials)';
				for( field = trial_fields )
					data.(field{1}) = { obj.trials.(field{1}) };
				end
			end

			% save data
			save( [ path, fileName ], '-struct', 'data' );
		end
		
		function t = GetTFromFp( obj, code )
			t = -0.01 * MK_CONSTANTS.TIME_UNIT;
			if obj.nTrials == 0
				return;
			end

			switch code
				case REX_CODE_MAP.FPON
					stims = { obj.trials.fp };
				case REX_CODE_MAP.RFON
					stims = { obj.trials.rf };
				case REX_CODE_MAP.RF2ON
					stims = { obj.trials.rf2 };
				case REX_CODE_MAP.CUEON
					stims = { obj.trials.cue };
				case REX_CODE_MAP.CUE2ON
					stims = { obj.trials.cue2 };
				case REX_CODE_MAP.JMP1ON
					stims = { obj.trials.jmp1 };
				case REX_CODE_MAP.JMP2ON
					stims = { obj.trials.jmp2 };
				otherwise
					return;
			end

			stims( [obj.trials.type] == TRIAL_TYPE_DEF.UNKNOWN ) = [];
			if( isempty(stims) )
				return;
			end
			nT = size( stims{1}, 2 );
			stims = [ stims{:} ];

			fp = {obj.trials.fp};
			fp( [obj.trials.type] == TRIAL_TYPE_DEF.UNKNOWN ) = [];
			fp = [ fp{:} ];

			% remove stimuli never appeared
			index = find( [ stims.tOn ] < 0 );
			if( ~isempty(index) )
				fp( ceil( index / nT ) ) = [];
				index2 = zeros( 1, size( unique(ceil(index/nT)), 2 ) * nT );
				for( i = 1 : nT )
					index2( i : nT : end - nT + i ) = unique( ceil(index/nT) * nT ) - nT + i;
				end
				stims(index2) = [];
				if( isempty(stims) )
					return;
				end
			end

			t = ones(1,nT) * 0.01 * MK_CONSTANTS.TIME_UNIT;
			for( i = 1 : nT )
				t(i) = mean( [ stims( i : nT : end - nT + i ).tOn ] - [ fp.tOn ] );
			end
		end		
		
		function MainSequence( obj, properties, newFigure, trialByTrial )
			%% Usage: obj.MainSequence( [ properties = 'b.', newFigure = true, trialByTrial = true ] )
			if( nargin() == 1 )
				properties = 'b.';
			end
			if( nargin() <= 2 )
				newFigure = true;
			end
			if( nargin() <= 3 )
				trialByTrial = true;
			end
			if( nargin() > 4 )
				disp( 'Usage: obj.MainSequence( [ properties = ''b.'', newFigure = true, trialByTrial = true ] )' );
				return;
			end

			if newFigure
				figure;
			end

			hold on;
			if(trialByTrial)
				for i = 1 : obj.nTrials
					obj.trials(i).MainSequence( properties, false, false );
				end
			else
				saccades = [ obj.trials.saccades ];
				if( ~isempty(saccades) )
					plot( log10( [saccades.amplitude] ), log10( [saccades.peakSpeed] ),	properties, 'tag', obj.blockName );
				end
			end
			hold off;
		end

		function out_handle = MainSeqDensity( obj, newFigure, msd_handle, step, c_map )
			%% Usage: obj.MainSeqDensity( [ newFigure=false, msd_handle=[], step=0.01, c_map='hot' ] )
			if( nargin() == 1 )
				newFigure = false;
			end
			if( nargin() <= 2 )
				msd_handle = [];
			end
			if( nargin() <= 3 )
				step = 0.01;
			end
			if( nargin <= 4 )
				c_map = 'hot';
			end
			if( nargin > 5 )
				disp( 'Usage: out_handle = obj.MainSeqDensity( [ newFigure=false, msd_handle=[], step=0.01, c_map=''hot'' ] )' );
				return;
			end

			if newFigure
				figure;
			end

			if( isempty(obj.trials) )
				out_handle = msd_handle;
				return;
			end

			saccades = [ obj.trials.saccades ];
			if( isempty(saccades) )
				out_handle = msd_handle;
				return;
			end

			min_amp = -2;
			max_amp = 3;
			min_vel = 0;
			max_vel = 3;
			size_x = ( max_amp - min_amp ) / step;
			size_y = ( max_vel - min_vel ) / step;			

			if( ishandle(msd_handle) )
				data = get( msd_handle, 'CData' )';
			else
				data = zeros( size_x + 1, size_y + 1 );
			end

			edge = cell(1,2);
			edge{1} = min_amp : step : max_amp;
			edge{2} = min_vel : step : max_vel;
			
			data = data + hist3( [ log10([saccades.amplitude]); log10([saccades.peakSpeed] ) ]', 'edges', edge);
				% data: x along the 1st dimension of the array; y along the 2nd dimension
			out_handle = pcolor( edge{1}, edge{2}, data' );	% data' matches a rectangular coordinate
			colormap(c_map);
		end
		
		function ShowTimeLine( obj, newFigure )
			if( nargin() == 1 )
				newFigure = true;
			end
			if( newFigure )
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'Task' );
				set( gca, 'color', [0 0 0] );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
				jf.setMaximized(1);
			end

			if( obj.nTrials == 0 )
				return;
			end

			hold on;
			title( 'Time Line' );
			h = [];

			trials = [ obj.trials( [obj.trials.type] ~= TRIAL_TYPE_DEF.UNKNOWN ) ];
            if( isempty(trials) ), return; end
			tFp = [ trials.fp ];
			stim_names = { 'rf', 'cue', 'cue2', 'rf2', 'jmp1' };
			colors	   = [ 'b',  'g',   'c',    'r',   'y'   ];
			stim_codes = [ REX_CODE_MAP.RFON, REX_CODE_MAP.CUEON, REX_CODE_MAP.CUE2ON, REX_CODE_MAP.RF2ON, REX_CODE_MAP.JMP1ON ];
			for( i = 1 : 5 )
				stims = [ trials.(stim_names{i}) ];
                if( isempty(stims) ), continue; end
				t = [ stims.tOn ] - [ tFp.tOn ];
				t( t <= 0 ) = NaN;
				plot( t, 1:size(t,2), 'color', colors(i), 'linestyle', 'none', 'marker', '.', 'markersize', 1, 'tag', obj.blockName );
				h = [ h, plot( ones(1,2) * obj.GetTFromFp( stim_codes(i) ), get(gca,'ylim'),...
							   [ colors(i), ':' ], 'tag', obj.blockName, 'DisplayName', stim_names{i} ) ];
				text( obj.GetTFromFp( stim_codes(i) ), obj.nTrials/6*i, stim_names{i}, 'color', 'w', 'HorizontalAlign', 'center' );
			end

			h = [ plot( [0,0], get(gca,'ylim'), 'w', 'DisplayName', 'fp' ), h ];
			hold off;

			if( newFigure )
				set( legend(h), 'TextColor', [1 1 1], 'EdgeColor', [1 1 1]);
			end
		end

		function ShowFPWindow( obj, trialByTrial )
            if( nargin() == 1 )
                trialByTrial = false;
            end
			if( isempty(obj.trials(1).eyeTrace) )
				disp( 'No eye trace found!' );
				return;
			end
			figure;
			hold on;

			breaks = obj.trials( [obj.trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
			x = zeros(size(breaks));
			y = zeros(size(breaks));
			for( i = 1 : size(breaks,2) )
				x(i) = breaks(i).eyeTrace.x( vpa( breaks(i).GetBreak(true) / MK_CONSTANTS.TIME_UNIT * 1000 ) );
				y(i) = breaks(i).eyeTrace.y( vpa( breaks(i).GetBreak(true) / MK_CONSTANTS.TIME_UNIT * 1000 ) );
				if( trialByTrial )
					plot( x(i), y(i), 'b.', 'tag', num2str(breaks(i).trialIndex), 'DisplayName', num2str(breaks(i).trialIndex) );
				end
			end
			if( ~trialByTrial )
				plot( x, y, 'b.' );
			end
		end

		function CheckEyeTrace( obj )
			if( isempty(obj.trials(1).eyeTrace) )
				disp( 'No eye trace found!' );
				return;
			end
			figure( 'NumberTitle', 'off', 'tag', '1', 'name', sprintf( 'Eye Trace of block ''%s''  ||  iTrial: 1', obj.blockName ), 'KeyPressFcn', @checkEyeTrace );
			obj.trials(1).PlotEyeTrace(0);

			function checkEyeTrace( hFig, evnt )
				iTrial = sscanf( get( hFig, 'tag' ), '%d' );
				switch evnt.Key
					case 'leftarrow'					
						iTrial = iTrial - 1;
					case 'downarrow'
						iTrial = iTrial - 100;
					case { 'hyphen', 'subtract' }
						iTrial = iTrial - 1000;
					case 'rightarrow'
						iTrial = iTrial + 1;
					case 'uparrow'
						iTrial = iTrial + 100;
					case { 'equal', 'add' }
						iTrial = iTrial + 1000;
					case 'return'
						tmp = sscanf( input('iTrial: ','s'), '%d' );
                        if( ~isempty(tmp) ) iTrial = tmp; end
					otherwise
						return;
				end
				if( iTrial < 1 ) iTrial = 1; end
				if( iTrial > obj.nTrials ) iTrial = obj.nTrials; end

				set( gcf, 'tag', num2str(iTrial), 'name', sprintf( 'Eye Trace of block ''%s''  ||  iTrial: %d', obj.blockName, iTrial ) );

				cla;
				obj.trials(iTrial).PlotEyeTrace(0);
			end
		end


		function ReSorting( obj, nUnits )
			units = [obj.trials.units];
			spikes = [units.spikes];
			iUnit = ToolKit.SpikeSorting( spikes, nUnits, true );
			iSpike = 1;
			for( iTrial = 1 : obj.nTrials )
				units = [obj.trials(iTrial).units];
				spikes = [units.spikes];
				t = [units.times];
				for( k = 1 : 5 )
					index = iUnit( iSpike : iSpike + size(spikes,2)-1 ) == k;
					obj.trials(iTrial).units(k).spikes = spikes(:,index);
					obj.trials(iTrial).units(k).times = t(index);
				end
			end
		end

	end

end