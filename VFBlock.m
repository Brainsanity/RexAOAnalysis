classdef VFBlock < RexBlock

	properties
		Conditions;
	end

	methods

		function obj = VFBlock( blockName, data, dataSrc, fieldsFlag, calibration )
			obj = obj@RexBlock( blockName, data, dataSrc, fieldsFlag, calibration );
			
			obj.blockType = 'Visual flash';


		end


		function AnaActivity(obj)

			vf1 = [obj.trials.vf1];
			vf1( [vf1.tOn] < 0 ) = [];
			vfLocs = unique( [ vf1.x; vf1.y ]', 'rows' )';

			% vf2 = [obj.trials.vf2];
			% vf2( [vf2.tOn] < 0 ) = [];
			% vfLocs = unique( [ vf2.x; vf2.y ]', 'rows' )';

			% [ X Y ] = meshgrid( -12:8:12, -9:6:9 );
			% vfLocs = [ reshape(X,1,[]); reshape(Y,1,[]) ];
			clear X Y;

			rf = [obj.trials.rf];
			rf( [rf.tOn] < 0 ) = [];
			% vfLocs = unique( [ rf.x; rf.y ]', 'rows' )';


			% structure specify the way to seperate different conditions; and event to align spikes:
			obj.Conditions.alignedTo		= 'vf1';			% name of event used to align spikes times, it can also be 'response' and 'reward'
			obj.Conditions.evnt1.name		= 'vf1';			% name of the 1st event the location of which is used
			obj.Conditions.evnt1.locs		= vfLocs;			% possible locations
			obj.Conditions.evnt1.center		= 'zero';			% reference center for possible locations, the value can be any event name or 'zero'
				%If event2 is defined, then each condition is specified by each combination of event1 and event2
			obj.Conditions.evnt2			= [];
			% obj.Conditions.evnt2.name		= [];				% name of the 2nd event the location of which is used
			% obj.Conditions.evnt2.locs		= [];				% possible locations
			% obj.Conditions.evnt2.center		= [];				% reference center for possible locations, the value can be any event name or 'zero'
			obj.Conditions.nConditions		= size(vfLocs,2);	% number of conditions

			convKernel = ones(1,21)/0.021;
			convKernel = normpdf( -3 : 0.15 : 3, 0, 1 ) / sum( normpdf( -3 : 0.15 : 3, 0, 1 ) ) * 1000;		% -20ms : 20ms

			%% collect data
			

			units = reshape( [obj.trials.units], 5, [] );	% each row containing spikes from different trials of the same unit, while each column containinig spikes of all units from one trial


			timeRange = [-100 300];	% in ms
			highRate = 150;	% upper limit for firing rate
			PlotColors = 'wgycr';


			%% show shapes
			isShowShape = true;
			isShowShape = false;
			if( isShowShape )
				spkConvStep = 0.3;			
				spkConvKer = normpdf( -3:spkConvStep:3, 0, 1 ) / sum( normpdf( -3:spkConvStep:3, 0, 1 ) );
				kerLength = 3/spkConvStep*2+1;
				for( iUnit = 1 : 5 )
					%% plot shapes
					spikes = [units(iUnit,:).spikes];		% each column is one spike
					for( k = 1 : size(spikes,2) )
						tmp = spikes(:,k);
						spikes( (kerLength-1)/2+1 : 96-(kerLength-1)/2, k ) = conv( tmp, spkConvKer, 'valid' );

						% border process
						for( m = 1 : (kerLength-1)/2 )
							spikes(m,k) = sum( tmp( 1 : m+(kerLength-1)/2 )' .* spkConvKer( (kerLength-1)/2-m+2 : end ) ) / sum( spkConvKer( (kerLength-1)/2-m+2 : end ) );
							spikes(97-m,k) = sum( tmp( 97-m-(kerLength-1)/2 : end )' .* spkConvKer( 1 : (kerLength-1)/2+m ) ) / sum( spkConvKer( 1 : (kerLength-1)/2+m ) );
						end
					end
					spikes( 97, : ) = NaN;
					set( figure, 'NumberTitle', 'off', 'name', sprintf( 'Shape of Segment: %d', iUnit-1 ) );
					hold on;
					set(gca,'color','k');
					plot( repmat( 1:97, 1, size(spikes,2) ), spikes(:), 'color', PlotColors(iUnit) );
				end
			end
			% return;


			%% show activities
			
			% open axes
			for( iUnit = 5:-1:1 )
				PlotHandles(iUnit).hFigure = figure;
				clf;
				set( PlotHandles(iUnit).hFigure, 'NumberTitle', 'off', 'name', sprintf( 'Segmentation %d    nTrials: %d', iUnit-1, obj.nTrials ), 'color', 'k' );

				Rows = unique( vfLocs(2,:) );
				nRows = size(Rows,2);
				Columns = unique( vfLocs(1,:) );
				nColumns = size(Columns,2);

				wa = 0.9/nColumns;	% width of axes
				ha = 0.9/nRows;	% height of axes
				we = ( 1/nColumns - wa ) / 2; % width of edge
				he = ( 1/nRows - ha ) / 2; % height of edge
				for( iCondition = obj.Conditions.nConditions : -1 : 1 )
					iCol = find( vfLocs(1,iCondition) == Columns );
					iRow = find( vfLocs(2,iCondition) == Rows );
					PlotHandles(iUnit).hAxis( iCondition ) = axes( 'position', [ we+(iCol-1)*(1/nColumns), he+(iRow-1)*(1/nRows), wa, ha ],...
																		'color', 'k',...
																		'XColor', [0.5 0.5 0.5],...
																		'YColor', [0.5 0.5 0.5],...
																		'XLim', timeRange,...
																		'YLim', [ 0 highRate ],...
																		'XTickLabel', [],...
																		'YTickLabel', [],...
																		'XGrid', 'on',...
																		'YGrid', 'on' );
					hold on;
					plot( [0 0], [0 highRate], 'w:' );
					% plot( [50 50], [0 obj.highRate], 'w:' );
					% plot( [100 100], [0 obj.highRate], 'w:' );

					SPKTimes{iCondition, iUnit} = {NaN};	% initialize SPKTimes
				end
			end

			% process data and show activities


			%%%%%%%%%%%%%%%%%%%
			for( iTrial = 1 : obj.nTrials )	% for each trial
				% if( obj.trials(iTrial).vf1.tOn < 0 || obj.trials(iTrial).vf1.x ~= 22.5 || obj.trials(iTrial).vf1.y ~= 16.5 )
				% 	continue;
				% end
				% if( obj.trials(iTrial).type ~= 'e' ) continue; end

				% get all conditions repeats of this trial
				if( isempty(obj.Conditions.evnt2) )		% conditions seperated only by event1
					conRepeats = [ obj.trials(iTrial).(obj.Conditions.evnt1.name) ];	% repeats of a condition event
					if( ~strcmpi( obj.Conditions.evnt1.center, 'zero' ) )
						center = [ obj.trials(iTrial).(obj.Conditions.evnt1.center) ];
						centerX = {center.x};
						centerY = {center.y};
						if( size(center,2) ~= size(conRepeats,2) )
							tmpX = num2cell( [conRepeats.x] - centerX{1} );
							[conRepeats.x] = tmpX{:};
							tmpY = num2cell( [conRepeats.y] - centerY{1} );
							[conRepeats.y] = tmpY{:};
						else
							tmpX = num2cell( [conRepeats.x] - [centerX{:}] );
							[conRepeats.x] = tmpX{:};
							tmpY = num2cell( [conRepeats.y] - [centerY{:}] );
							[conRepeats.y] = tmpY{:};
						end
					end
				end
				nConRepeats = size(conRepeats,2);

				% get time alignments
				alignField = [ obj.trials(iTrial).(obj.Conditions.alignedTo) ];	% time for spikes times alignment
				if( strcmp( obj.Conditions.alignedTo, 'Saccades' ) )
					if( ~isempty( obj.trials(iTrial).iResponse1 ) )
						alignT = obj.trials(iTrial).Saccades( obj.trials(iTrial).iResponse1 ).latency / MK_CONSTANTS.TIME_UNIT * 1000;
					else
						alignT = 0;
					end
				else
					alignT = [alignField.tOn] / MK_CONSTANTS.TIME_UNIT * 1000 ;
				end
				nAlignTs = size(alignT,2);

 				% for each condition event repeat
				for( iConRepeat = 1:nConRepeats )
					if( isempty(obj.Conditions.evnt2) )
						iCondition = find( conRepeats(iConRepeat).x == obj.Conditions.evnt1.locs(1,:) & conRepeats(iConRepeat).y == obj.Conditions.evnt1.locs(2,:) );
					end
					if( isempty(iCondition) )
						continue;
					end

					for( iUnit = 5 : -1 : 1 )	% for each specified units
						if( isnan( SPKTimes{iCondition,iUnit}{1} ) )
							SPKTimes{iCondition,iUnit} = { obj.trials(iTrial).units(iUnit).times - alignT( ceil( iConRepeat*nAlignTs/nConRepeats ) ) };
						else
							SPKTimes{iCondition,iUnit} = [ SPKTimes{iCondition,iUnit}, { obj.trials(iTrial).units(iUnit).times - alignT( ceil( iConRepeat*nAlignTs/nConRepeats ) ) } ];
						end
					end
				end
			end

			for( iUnit = 1 : 5 )	% for each segmented unit				
				set( PlotHandles(iUnit).hFigure, 'name', sprintf( 'Segmentation %d    nTrials: %d', iUnit-1, obj.nTrials ) );
				for( iCondition = 1 : obj.Conditions.nConditions )
					cla( PlotHandles(iUnit).hAxis(iCondition) );
					
					if( iCondition < obj.Conditions.nConditions + 1 )
						data = SPKTimes{iCondition,iUnit};
					else
						data = [ SPKTimes{:,iUnit} ];		% sum up all conditions
					end

					x = [data{:}];
					
					% plot rasters
					y = [];
					nConOns = size( data, 2 );
					for( iConOn = 1 : nConOns )	% for each time in this condition (condition on)
						y = [ y, highRate * ( 1 - ( iConOn - 1 ) / max( [ nConOns 10 ] ) / 4 ) * ones( size( data{iConOn} ) ) ];	% 1st row at panel top
					end
					X( 3 : 3 : size(x,2) * 3 ) = NaN;
					X( 2 : 3 : size(x,2) * 3 ) = x;
					X( 1 : 3 : size(x,2) * 3 ) = x;
					Y( 3 : 3 : size(x,2) * 3 ) = NaN;
					Y( 2 : 3 : size(x,2) * 3 ) = y;
					Y( 1 : 3 : size(x,2) * 3 ) = y - 0.9 * highRate / max( [ nConOns 10 ] ) / 4;

					if( iCondition < obj.Conditions.nConditions+1 || obj.IsShowSumUp )
						plot( PlotHandles(iUnit).hAxis(iCondition), X, Y, PlotColors( mod(iUnit-1,5) + 1 ) );

						% plot firing rate
						if( ~isempty(x) )
							[ data, edges ] = hist( x, round(min(x))-0.5 : round(max(x))+0.5 );
							plot( PlotHandles(iUnit).hAxis(iCondition), edges, conv( data/nConOns, convKernel, 'same' ), PlotColors( mod(iUnit-1,5) + 1 ) );
						end

						plot( [0 0], [0 highRate], 'w:' );
					end

					clear X Y;

				end
			end
			%%%%%%%%%%%%%%%%%%%

		end



		function AnaAlloActivity(obj)

			vf1 = [obj.trials.vf1];
			vf1( [vf1.tOn] < 0 ) = [];
			vf1Locs = unique( [ vf1.x; vf1.y ]', 'rows' )';
			% vf1Locs = vf1Locs(:,1:8);

			vf2 = [obj.trials.vf2];
			vf2( [vf2.tOn] < 0 ) = [];
			vfLocs = unique( [ vf2.x; vf2.y ]', 'rows' )';

			[ X Y ] = meshgrid( -12:8:12, -9:6:9 );
			[ X Y ] = meshgrid( -35:11:42, -28:8:28 );
			% vfLocs = [ reshape(X,1,[]); reshape(Y,1,[]) ];
			clear X Y;


			% structure specify the way to seperate different conditions; and event to align spikes:
			obj.Conditions.alignedTo		= 'vf2';			% name of event used to align spikes times, it can also be 'response' and 'reward'
			obj.Conditions.evnt1.name		= 'vf1';			% name of the 1st event the location of which is used
			obj.Conditions.evnt1.locs		= vf1Locs;			% possible locations
			obj.Conditions.evnt1.center		= 'zero';			% reference center for possible locations, the value can be any event name or 'zero'
				%If event2 is defined, then each condition is specified by each combination of event1 and event2
			% obj.Conditions.evnt2			= [];
			obj.Conditions.evnt2.name		= 'vf2';				% name of the 2nd event the location of which is used
			obj.Conditions.evnt2.locs		= vfLocs;				% possible locations
			obj.Conditions.evnt2.center		= 'zero';				% reference center for possible locations, the value can be any event name or 'zero'
			obj.Conditions.nConditions		= size(vfLocs,2) * size(vf1Locs,2);	% number of conditions

			convKernel = ones(1,21)/0.021;
			convKernel = normpdf( -3 : 0.15 : 3, 0, 1 ) / sum( normpdf( -3 : 0.15 : 3, 0, 1 ) ) * 1000;		% -20ms : 20ms

			%% collect data
			

			units = reshape( [obj.trials.units], 5, [] );	% each row containing spikes from different trials of the same unit, while each column containinig spikes of all units from one trial


			timeRange = [-100 300];	% in ms
			highRate = 200;	% upper limit for firing rate
			PlotColors = 'wgycr';


			%% show shapes
			% isShowShape = true;
			isShowShape = false;
			if( isShowShape )
				spkConvStep = 0.3;			
				spkConvKer = normpdf( -3:spkConvStep:3, 0, 1 ) / sum( normpdf( -3:spkConvStep:3, 0, 1 ) );
				kerLength = 3/spkConvStep*2+1;
				for( iUnit = 1 : 5 )
					%% plot shapes
					spikes = [units(iUnit,:).spikes];		% each column is one spike
					for( k = 1 : size(spikes,2) )
						tmp = spikes(:,k);
						spikes( (kerLength-1)/2+1 : 96-(kerLength-1)/2, k ) = conv( tmp, spkConvKer, 'valid' );

						% border process
						for( m = 1 : (kerLength-1)/2 )
							spikes(m,k) = sum( tmp( 1 : m+(kerLength-1)/2 )' .* spkConvKer( (kerLength-1)/2-m+2 : end ) ) / sum( spkConvKer( (kerLength-1)/2-m+2 : end ) );
							spikes(97-m,k) = sum( tmp( 97-m-(kerLength-1)/2 : end )' .* spkConvKer( 1 : (kerLength-1)/2+m ) ) / sum( spkConvKer( 1 : (kerLength-1)/2+m ) );
						end
					end
					spikes( 97, : ) = NaN;
					set( figure, 'NumberTitle', 'off', 'name', sprintf( 'Shape of Segment: %d', iUnit-1 ) );
					hold on;
					set(gca,'color','k');
					plot( repmat( 1:97, 1, size(spikes,2) ), spikes(:), 'color', PlotColors(iUnit) );
				end
			end
			% return;


			%% show activities

			nUnits = 3;

			% open axes
			for( iUnit = nUnits:-1:1 )
				PlotHandles(iUnit).hFigure = figure;
				clf;
				set( PlotHandles(iUnit).hFigure, 'NumberTitle', 'off', 'name', sprintf( 'Segmentation %d    nTrials: %d', iUnit-1, obj.nTrials ), 'color', 'k' );

				Rows1 = unique( obj.Conditions.evnt1.locs(2,:) );	% vertical locations of 1st event
				nRows1 = size(Rows1,2);
				Columns1 = unique(obj.Conditions.evnt1.locs(1,:) );	% horizontal locations of 1st event
				nColumns1 = size(Columns1,2);

				wg = 0.98/nColumns1;	% width of each group; each event1 location occupies one group
				wge = ( 1/nColumns1 - wg ) / 2;
				hg = 0.95/nRows1;		% height of each group
				hge = ( 1/nRows1 - hg ) / 2;

				axes( 'position', [0 0 1 1], 'visible', 'off', 'NextPlot', 'add', 'xlim', [0 1], 'ylim', [0 1] );
				for( x = (1:nColumns1-1) * (wg+2*wge) )
					plot( [x x], [0 1], 'w--', 'LineWidth', 400*wge );
				end
				for( y = (1:nRows1-1) * (hg+2*hge) )
					plot( [0 1], [y y], 'w--', 'LineWidth', 400*hge );
				end

				Rows2 = unique( obj.Conditions.evnt2.locs(2,:) );	% vertical locations of 2nd event
				nRows2 = size(Rows2,2);
				Columns2 = unique( obj.Conditions.evnt2.locs(1,:) );	% horizontal locations of 2nd event
				nColumns2 = size(Columns2,2);

				wa = wg/nColumns2*0.9;	% width of axes;	each event1 & event2 combination occupies one axes
				ha = hg/nRows2*0.9;		% height of axes
				we = ( wg/nColumns2 - wa) / 2; % width of axes edge
				he = ( hg/nRows2 - ha ) / 2; % height of exes edge
				for( iCondition = obj.Conditions.nConditions : -1 : 1 )
					iGroup = floor( (iCondition-1) / size(obj.Conditions.evnt2.locs,2) ) + 1;
					iGroupX = find( obj.Conditions.evnt1.locs(1,iGroup) == Columns1 );
					iGroupY = find( obj.Conditions.evnt1.locs(2,iGroup) == Rows1 );
					iAxes = mod( (iCondition-1), size(obj.Conditions.evnt2.locs,2) ) + 1;
					iAxesX = find( obj.Conditions.evnt2.locs(1,iAxes) == Columns2 );
					iAxesY = find( obj.Conditions.evnt2.locs(2,iAxes) == Rows2 );
					PlotHandles(iUnit).hAxis( iCondition ) = axes( 'position', [ (iGroupX-1)*(wg+2*wge) + wge + (iAxesX-1)*(wa+2*we) + we, (iGroupY-1)*(hg+2*hge) + hge + (iAxesY-1)*(ha+2*he) + he, wa, ha ],...
																		'color', 'k',...
																		'XColor', [0.5 0.5 0.5],...
																		'YColor', [0.5 0.5 0.5],...
																		'XLim', [-100 300],...%timeRange,...
																		'YLim', [ 0 highRate ],...
																		'XTickLabel', [],...
																		'YTickLabel', [],...
																		'XGrid', 'on',...
																		'YGrid', 'on' );
					hold on;
					% plot( [0 0], [0 highRate], 'w:' );
					% plot( [50 50], [0 obj.highRate], 'w:' );
					% plot( [100 100], [0 obj.highRate], 'w:' );

					SPKTimes{iCondition, iUnit} = {NaN};	% initialize SPKTimes
				end
			end

			% process data and show activities


			%%%%%%%%%%%%%%%%%%%
			for( iTrial = 1 : obj.nTrials )	% for each trial

				% get all conditions repeats of this trial
				if( ~isempty(obj.Conditions.evnt2.name) )
					conEvnts = [ obj.Conditions.evnt1, obj.Conditions.evnt2 ];
				else
					conEvnts = [obj.Conditions.evnt1];
				end
				for( k = size(conEvnts,2) : -1 : 1 )
					conRepeats{k} = [ obj.trials(iTrial).(conEvnts(k).name) ];	% repeats of condition event k
					if( ~strcmpi( conEvnts(k).center, 'zero' ) )
						center = [ obj.trials(iTrial).(conEvnts(k).center) ];
						centerX = {center.x};
						centerY = {center.y};
						if( size(center,2) ~= size(conRepeats{k},2) )
							tmpX = num2cell( [conRepeats{k}.x] - centerX{1} );
							[conRepeats{k}.x] = tmpX{:};
							tmpY = num2cell( [conRepeats{k}.y] - centerY{1} );
							[conRepeats{k}.y] = tmpY{:};
						else
							tmpX = num2cell( [conRepeats{k}.x] - [centerX{:}] );
							[conRepeats{k}.x] = tmpX{:};
							tmpY = num2cell( [conRepeats{k}.y] - [centerY{:}] );
							[conRepeats{k}.y] = tmpY{:};
						end
					end
					% [ ~, index ] = unique( [ conRepeats{k}.x; conRepeats{k}.y ]', 'rows' );		% remove replicates
					% conRepeats{k} = conRepeats{k}(index');
					nConRepeats(k) = size(conRepeats{k},2);
				end

				% get time alignments
				alignField = [ obj.trials(iTrial).(obj.Conditions.alignedTo) ];	% time for spikes times alignment
				if( strcmp( obj.Conditions.alignedTo, 'Saccades' ) )
					if( ~isempty( obj.trials(iTrial).iResponse1 ) )
						alignT = obj.trials(iTrial).Saccades( obj.trials(iTrial).iResponse1 ).latency / MK_CONSTANTS.TIME_UNIT * 1000;
					else
						alignT = 0;
					end
				else
					alignT = [alignField.tOn] / MK_CONSTANTS.TIME_UNIT * 1000 ;
				end
				nAlignTs = size(alignT,2);

 				% for each condition event repeat
				for( iConRepeat = 1 : prod( nConRepeats ) )
					if( isempty(obj.Conditions.evnt2.name) )
						iCondition = find( conRepeats{1}(iConRepeat).x == obj.Conditions.evnt1.locs(1,:) & conRepeats{1}(iConRepeat).y == obj.Conditions.evnt1.locs(2,:) );
					else
						iCondition = ( find( conRepeats{1}( floor((iConRepeat-1)/nConRepeats(2)) + 1 ).x == obj.Conditions.evnt1.locs(1,:) &...
											 conRepeats{1}( floor((iConRepeat-1)/nConRepeats(2)) + 1 ).y == obj.Conditions.evnt1.locs(2,:) ) - 1 )...
									 * size(obj.Conditions.evnt2.locs,2) + ...
									 find( conRepeats{2}( mod(iConRepeat-1,nConRepeats(2)) + 1 ).x == obj.Conditions.evnt2.locs(1,:) &...
										   conRepeats{2}( mod(iConRepeat-1,nConRepeats(2)) + 1 ).y == obj.Conditions.evnt2.locs(2,:) );

					end
					if( isempty(iCondition) )
						continue;
					end

					for( iUnit = nUnits : -1 : 1 )	% for each specified units
						if( isnan( SPKTimes{iCondition,iUnit}{1} ) )
							SPKTimes{iCondition,iUnit} = { obj.trials(iTrial).units(iUnit).times - alignT( ceil( iConRepeat*nAlignTs/prod(nConRepeats) ) ) };
						else
							SPKTimes{iCondition,iUnit} = [ SPKTimes{iCondition,iUnit}, { obj.trials(iTrial).units(iUnit).times - alignT( ceil( iConRepeat*nAlignTs/prod(nConRepeats) ) ) } ];
						end
					end
				end
			end

			for( iUnit = 1 : nUnits )	% for each segmented unit				
				% set( PlotHandles(iUnit).hFigure, 'name', sprintf( 'Segmentation %d    nTrials: %d', iUnit-1, obj.nTrials ) );
				for( iCondition = 1 : obj.Conditions.nConditions )
					cla( PlotHandles(iUnit).hAxis(iCondition) );
					
					if( iCondition < obj.Conditions.nConditions + 1 )
						data = SPKTimes{iCondition,iUnit};
					else
						data = [ SPKTimes{:,iUnit} ];		% sum up all conditions
					end

					x = [data{:}];
					
					% plot rasters
					y = [];
					nConOns = size( data, 2 );
					for( iConOn = 1 : nConOns )	% for each time in this condition (condition on)
						y = [ y, highRate * ( 1 - ( iConOn - 1 ) / max( [ nConOns 10 ] ) / 4 ) * ones( size( data{iConOn} ) ) ];	% 1st row at panel top
					end
					X( 3 : 3 : size(x,2) * 3 ) = NaN;
					X( 2 : 3 : size(x,2) * 3 ) = x;
					X( 1 : 3 : size(x,2) * 3 ) = x;
					Y( 3 : 3 : size(x,2) * 3 ) = NaN;
					Y( 2 : 3 : size(x,2) * 3 ) = y;
					Y( 1 : 3 : size(x,2) * 3 ) = y - 0.9 * highRate / max( [ nConOns 10 ] ) / 4;

					if( iCondition < obj.Conditions.nConditions+1 || obj.IsShowSumUp )
						plot( PlotHandles(iUnit).hAxis(iCondition), X, Y, PlotColors( mod(iUnit-1,5) + 1 ) );

						% plot firing rate
						if( ~isempty(x) )
							[ data, edges ] = hist( x, round(min(x))-0.5 : round(max(x))+0.5 );
							plot( PlotHandles(iUnit).hAxis(iCondition), edges, conv( data/nConOns, convKernel, 'same' ), PlotColors( mod(iUnit-1,5) + 1 ) );
						end

						plot( [0 0], [0 highRate], 'w:' );
					end

					clear X Y;

				end
			end
			%%%%%%%%%%%%%%%%%%%

		end


		function ShowFlashPat(obj)
			%% show the pattern of visual flash stimulus
			%	here, we use vf2 for the flash dot and vf1 for the frame

			% screen height: 68cm
			% viewing distance: 58cm
			% screen resolution: 1280px X 720px
			% flash dot:
			%	Unit: 2px X 2px
			%	size: 6
			% frame:
			%	Unit:
			%		105px X 140px
			%		edge: 3px
			%	size: 1

			ViewDist = 58;	% viewing distance in centimeters
			ScreenHCM = 68;	% screen height in centimeters
			ScreenHPX = 720;	% screen height in pixels
			ScreenWPX = 1280;	% screen width in pixels

			flashSize = atan( 12 / ScreenHPX * ScreenHCM / ViewDist ) / pi * 180;	% size of flash dot in degrees
			frameSize = [138 103 3] / ScreenHPX * ScreenHCM;	% frame size in centimeters: width(edge center), height(edge center), edge width
			
			vf1 = [obj.trials.vf1];
			vf1( [vf1.tOn] < 0 ) = [];
			if( ~isempty(vf1) )
				vf1Locs = unique( [vf1.x; vf1.y]', 'rows' )';
			end

			vf2 = [obj.trials.vf2];
			vf2( [vf2.tOn] < 0 ) = [];
			if( ~isempty(vf2) )
				vf2Locs = unique( [vf2.x; vf2.y]', 'rows' )';
			else 	% flash with a frame, then vf1 is the frame and vf2 is the flash dot
				vf2Locs = vf1Locs;
				vf1Locs = [];
				vf2 = vf1;
				vf1 = [];
			end

			i = find( [vf2.tOn] > 0, 1, 'first' );
			if( ~isempty(i) )
				flashColor = [ vf2(i).red, vf2(i).green, vf2(i).blue ] / 255;
			end

			i = find( [vf1.tOn] > 0, 1, 'first'  );
			if( ~isempty(i) )
				frameColor = [ vf1(i).red, vf1(i).green, vf1(i).blue ] / 255;
			end

			figure;
			hold on;
			for( points = vf2Locs )	% for each flash dot
				rectangle( 'position', [ points(1) - flashSize/2, points(2) - flashSize/2, flashSize, flashSize ], 'LineStyle', 'none', 'FaceColor', flashColor );
			end

			for( frame = vf1Locs )
				center = ViewDist * tand(frame);	% center in centimeters
				left	= atan( ( center(1) - frameSize(1)/2 ) / ViewDist ) / pi * 180;	% left in degrees
				right	= atan( ( center(1) + frameSize(1)/2 ) / ViewDist ) / pi * 180;	% right in degrees
				bottom	= atan( ( center(2) - frameSize(2)/2 ) / ViewDist ) / pi * 180;	% bottom in degrees
				top		= atan( ( center(2) + frameSize(2)/2 ) / ViewDist ) / pi * 180; % top in degrees
				edgeWidth = atan( frameSize(3) / ViewDist ) / pi * 180;	% edge width in degrees
				rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% left line
				rectangle( 'position', [ right - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth  ], 'LineStyle', 'none', 'FaceColor', frameColor );	% right line
				rectangle( 'position', [ left - edgeWidth/2, top - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% top line
				rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% bottom line

			end

			axis( gca, 'equal' );
			set( gca, 'XTick', unique( [ vf1Locs(1,:) vf2Locs(1,:) ] ), 'YTick', unique( [ vf1Locs(2,:) vf2Locs(2,:) ] ), 'color', 'k', 'XLim', [-1 1] * atan( ScreenWPX/2 / ScreenHPX * ScreenHCM / ViewDist ) / pi * 180, 'YLim', [-1 1] * atan( ScreenHCM/2 / ViewDist ) / pi * 180 );

		end


		function ShowRF( obj, timeRange )
			%% timerange: in ms

			% timeRange = [25 175];	% in ms

			% frame locations
			frameEvntName = 'vf1';
			frame = [obj.trials.vf1];
			frame( [frame.tOn] < 0 ) = [];
			if( ~isempty(frame) )
				frameLocs = unique( [frame.x; frame.y]', 'rows' )';
			else
				disp('No vf1 data!!!');
				return;
			end

			% flash locations
			flashEvntName = 'vf2';
			flash = [obj.trials.vf2];
			flash( [flash.tOn] < 0 ) = [];
			if( ~isempty(flash) )
				flashLocs = unique( [flash.x; flash.y]', 'rows' )';
			else 	% flash with a frame, then vf1 is the frame and vf2 is the flash dot
				flashEvntName = 'vf1';
				frameEvntName = [];
				flashLocs = frameLocs;
				frameLocs = [];
				flash = frame;
				frame = [];
			end

			%% initializations for data sets
			%  each row for one frame location, column for flash, page for unit
			if( isempty(frameLocs) )
				SPKCounts = zeros( 1, size(flashLocs,2), 5 );	% number of spikes for each condition
				flashCounts = zeros( 1, size(flashLocs,2), 5 );	% number of flashes presented in each condition
			else
				SPKCounts = zeros( size(frameLocs,2), size(flashLocs,2), 5 );
				flashCounts = zeros( size(frameLocs,2), size(flashLocs,2), 5 );
			end

			%% collect data set
			for( iTrial = 1 : obj.nTrials )
				% get frame location index
				if( isempty(frameLocs) )
					iFrame = 1;
				else
					frame = obj.trials(iTrial).(frameEvntName);
					if( size(frame,2) == 1 && frame.tOn > 0 )
						iFrame = find( frame.x == frameLocs(1,:) & frame.y == frameLocs(2,:) );
						if( size(iFrame,2) ~= 1 )
							continue;
						end
					else
						continue;
					end
				end

				% for each flash location
				flash = obj.trials(iTrial).(flashEvntName);
				flash( [flash.tOn] < 0 ) = [];
				for( i = 1 : size(flash,2) )
					iFlash = find( flash(i).x == flashLocs(1,:) & flash(i).y == flashLocs(2,:) );
					for( iUnit = 1 : 5 )
						SPKCounts(iFrame,iFlash,iUnit) = SPKCounts(iFrame,iFlash,iUnit) + ...
															sum( timeRange(1) <= obj.trials(iTrial).units(iUnit).times - flash(i).tOn / MK_CONSTANTS.TIME_UNIT * 1000 &...
																 obj.trials(iTrial).units(iUnit).times - flash(i).tOn / MK_CONSTANTS.TIME_UNIT * 1000 < timeRange(2) );
						flashCounts(iFrame,iFlash,iUnit) = flashCounts(iFrame,iFlash,iUnit) + 1;
					end
				end

			end

			%% calculate average firing rate during timeRange
			FR = SPKCounts ./ flashCounts / ( timeRange(2) - timeRange(1) ) * 1000;

			%% plot data
			ViewDist = 58;	% viewing distance in centimeters
			ScreenHCM = 68;	% screen height in centimeters
			ScreenHPX = 720;	% screen height in pixels
			frameSize = [138 103 3] / ScreenHPX * ScreenHCM;	% frame size in centimeters: width(edge center), height(edge center), edge width
			frameColor = [0 1 0];
			
			XTicks = unique(flashLocs(1,:));
			YTicks = unique(flashLocs(2,:));
			[X0 Y0] = meshgrid( XTicks, YTicks );
			for( iUnit = 1 : 4 )
				set( figure, 'NumberTitle', 'off', 'name', sprintf( 'iUnit: %d    time: [%d,%d]', iUnit-1, timeRange ) );
				colormap('hot');

				nFrames = size(frameLocs,2);
				if( isempty(frameLocs) ) nFrames = 1; end
				for( iFrame = 1 : nFrames )
					subplot( ceil(sqrt(nFrames)), ceil(nFrames/(ceil(sqrt(nFrames)))),iFrame);
					Z0 = reshape( FR(iFrame,:,iUnit), length(YTicks), length(XTicks) );
					Z0 = interp2( X0, Y0, Z0, XTicks(1):XTicks(end), (YTicks(1):YTicks(end))', 'linear' );
					set( pcolor( XTicks(1):XTicks(end), YTicks(1):YTicks(end), Z0 ), 'LineStyle', 'none' );
					colorbar;

					% show frame
					if( isempty(frameLocs) ) continue; end
					center = ViewDist * tand(frameLocs(:,iFrame));	% center in centimeters
					left	= atan( ( center(1) - frameSize(1)/2 ) / ViewDist ) / pi * 180;	% left in degrees
					right	= atan( ( center(1) + frameSize(1)/2 ) / ViewDist ) / pi * 180;	% right in degrees
					bottom	= atan( ( center(2) - frameSize(2)/2 ) / ViewDist ) / pi * 180;	% bottom in degrees
					top		= atan( ( center(2) + frameSize(2)/2 ) / ViewDist ) / pi * 180; % top in degrees
					edgeWidth = atan( frameSize(3) / ViewDist ) / pi * 180;	% edge width in degrees
					rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% left line
					rectangle( 'position', [ right - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth  ], 'LineStyle', 'none', 'FaceColor', frameColor );	% right line
					rectangle( 'position', [ left - edgeWidth/2, top - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% top line
					rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% bottom line
				end
				% pcolor( SPKCounts(:,:,iUnit) ./ flashCounts(:,:,iUnit) / ( timeRange(2) - timeRange(1) ) * 1000 );
			end

			return;
		end


		function CheckFlashPat(obj)			
			figure( 'NumberTitle', 'off', 'tag', '0', 'name', sprintf( 'Trial-by-trial flash pattern of block ''%s''  ||  iTrial: 1	|| trialType: %s', obj.blockName, obj.trials(1).type ), 'KeyPressFcn', @checkFlashPat );
			evt.Key = 'rightarrow';
			checkFlashPat( gcf, evt );

			function checkFlashPat( hFig, evnt )
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

				set( hFig, 'tag', num2str(iTrial), 'name', sprintf( 'Trial-by-trial flash pattern of block ''%s''  ||  iTrial: %d	|| trialType: %s', obj.blockName, iTrial, obj.trials(iTrial).type ) );
				child = get( gca, 'children' );
				for( i = 1 : size(child,1) )
					% set( child(i), 'FaceColor', get( child(i), 'FaceColor' ) / 2 );
					set( child(i), 'FaceColor', [0.3 0.3 0.3] );
				end

				vf1 = [obj.trials.vf1];
				vf1( [vf1.tOn] < 0 ) = [];
				if(isempty(vf1)) return; end
				vf1Locs = [vf1.x; vf1.y];
				frameColor = [ vf1(1).red, vf1(1).green, vf1(1).blue ] / 255;

				vf2 = [obj.trials.vf2];
				vf2( [vf2.tOn] < 0 ) = [];
				if( isempty(vf2) )	% visual_flash task
					vf2 = vf1;
					vf1 = [];
					vf2Locs = vf1Locs;
					vf1Locs = [];
					flashColor = frameColor;
				else 				% frame_flash task
					vf2Locs = [vf2.x; vf2.y];
					flashColor = [ vf2(1).red, vf2(1).green, vf2(1).blue ] / 255;
				end

				if( isempty(vf1) )
					vf2 = [obj.trials(iTrial).vf1];
					vf2( [vf2.tOn] < 0 ) = [];
				else
					vf1 = [obj.trials(iTrial).vf1];
					vf1( [vf1.tOn] < 0 ) = [];
					vf2 = [obj.trials(iTrial).vf2];
					vf2( [vf2.tOn] < 0 ) = [];
				end

				ViewDist = 58;	% viewing distance in centimeters
				ScreenHCM = 68;	% screen height in centimeters
				ScreenHPX = 720;	% screen height in pixels
				ScreenWPX = 1280;	% screen width in pixels

				flashSize = 2*atan( 12 / ScreenHPX * ScreenHCM / ViewDist ) / pi * 180;	% size of flash dot in degrees
				frameSize = [138 103 3] / ScreenHPX * ScreenHCM;	% frame size in centimeters: width(edge center), height(edge center), edge width

				for( i = 1 : size(vf2,2) )	% for each flash dot
					point = [vf2(i).x, vf2(i).y];
					rectangle( 'position', [ point(1) - flashSize/2, point(2) - flashSize/2, flashSize, flashSize ], 'LineStyle', 'none', 'FaceColor', flashColor );
				end

				for( i = 1 : size(vf1,2) )	% for each frame dot
					frame = [vf1(i).x, vf1(i).y];
					center = ViewDist * tand(frame);	% center in centimeters
					left	= atan( ( center(1) - frameSize(1)/2 ) / ViewDist ) / pi * 180;	% left in degrees
					right	= atan( ( center(1) + frameSize(1)/2 ) / ViewDist ) / pi * 180;	% right in degrees
					bottom	= atan( ( center(2) - frameSize(2)/2 ) / ViewDist ) / pi * 180;	% bottom in degrees
					top		= atan( ( center(2) + frameSize(2)/2 ) / ViewDist ) / pi * 180; % top in degrees
					edgeWidth = atan( frameSize(3) / ViewDist ) / pi * 180;	% edge width in degrees
					rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% left line
					rectangle( 'position', [ right - edgeWidth/2, bottom - edgeWidth/2, edgeWidth, top - bottom + edgeWidth  ], 'LineStyle', 'none', 'FaceColor', frameColor );	% right line
					rectangle( 'position', [ left - edgeWidth/2, top - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% top line
					rectangle( 'position', [ left - edgeWidth/2, bottom - edgeWidth/2, right - left + edgeWidth, edgeWidth ], 'LineStyle', 'none', 'FaceColor', frameColor );	% bottom line

				end

				axis( gca, 'equal' );
				set( gca, 'XTick', unique( [ vf1Locs(1,:) vf2Locs(1,:) ] ), 'YTick', unique( [ vf1Locs(2,:) vf2Locs(2,:) ] ), 'color', 'k', 'XLim', [-1 1] * atan( ScreenWPX/2 / ScreenHPX * ScreenHCM / ViewDist ) / pi * 180, 'YLim', [-1 1] * atan( ScreenHCM/2 / ViewDist ) / pi * 180 );
			end
		end


		function ShowFlashSequence( obj, x, y )
			%% x: horizontal location of the flash location; y: vertical location of the flash location
			%% we need to make sure that, for each flash location, the flash was presented during a similar time period across different frame locations.

			vf2 = [obj.trials.vf2];
			vf2( [vf2.tOn] < 0 ) = [];
			if( isempty(vf2) )
				disp( 'No frame displayed during this session!!!' );
				return;
			end

			set( figure, 'NumberTitle', 'off', 'name', sprintf( 'Flash loc (%d, %d)', x, y ) );
			hold on;
			vf1 = [obj.trials.vf1];
			vf1( [vf1.tOn] < 0 ) = [];
			if( isempty(vf1) )
				return;
			end

			vf1Locs = unique( [ vf1.x; vf1.y ]', 'rows' )';
			vf1Locs = vf1Locs(1,:) + vf1Locs(2,:) * i;

			sequence(2,1:obj.nTrials) = NaN;
			sequence(1,:) = 1:obj.nTrials;
			for( iTrial = 1:obj.nTrials )
				vf2 = [obj.trials(iTrial).vf2];
				vf2( [vf2.tOn] < 0 ) = [];
				if( ~isempty(vf2) && obj.trials(iTrial).vf1.tOn > 0 && any( [vf2.x] == x & [vf2.y] == y ) )
					index = find( obj.trials(iTrial).vf1.x + obj.trials(iTrial).vf1.y * i == vf1Locs );
					if( ~isempty(index) )
						sequence(2,iTrial) = index;
					end
				end
			end

			% plot( 1:size(vf1,2), [vf1.x], '*-', 'color', 'r' );	% horizontal locations of the frame
			% plot( 1:size(vf1,2), [vf1.y], '*-', 'color', 'b' );	% vertical locations of the frame

			plot( sequence(1,:), sequence(2,:), 'o-', 'color', 'g' );

			set( gca, 'ylim', [-1 5] );

		end

	end

end