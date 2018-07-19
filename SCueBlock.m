classdef SCueBlock < RexBlock

	properties ( SetAccess = public, GetAccess = public )
		% blockType = 'Spatial Cue Task';
	end

	methods
		%% SCueBlock: function description
		function obj = SCueBlock( blockName, data, dataSrc, fieldsFlag, hasCue )
			if( nargin() < 1 )
				blockName = [];
			end
			if( nargin() <= 1 )
				data = [];
			end
			if( nargin() <= 2 )
				dataSrc = RexBlock.REFINED_FILE;
			end
			if( nargin() <= 3 )
				fieldsFlag = DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX + DATA_FIELD_FLAG.EYETRACE;
            end
            if( nargin() <= 4 )
            	hasCue = true;	% by default, there is a cue in the task; 
            					% however, in the very beginning of the trainning, there might be no cue in the task
            end

			obj = obj@RexBlock( blockName, data, dataSrc, fieldsFlag );

			if( isempty( obj.trials ) )
				return;
			end

			%% spatial cue task specified code
			for( i = 1 : obj.nTrials )
				switch( obj.trials(i).type )
					case { TRIAL_TYPE_DEF.CORRECT, TRIAL_TYPE_DEF.ERROR }
						if( size(obj.trials(i).fp,2) ~= 1 || obj.trials(i).fp.tOn < 0 ||...
							size(obj.trials(i).rf,2) ~= 1 || obj.trials(i).rf.tOn < 0 || obj.trials(i).rf.nPats ~= 2 ||...
							size(obj.trials(i).rf2,2) ~= 1 || obj.trials(i).rf2.tOn < 0 || obj.trials(i).rf2.nPats ~= 2 ||...
							size(obj.trials(i).cue,2) ~= 1 || ( hasCue && ( obj.trials(i).cue.tOn < 0 || obj.trials(i).cue.nPats ~= 1 ) ) ||...
							size(obj.trials(i).cue2,2) ~= 1 || obj.trials(i).cue2.tOn >= 0 ||...
							size(obj.trials(i).jmp1,2) ~= 1 || obj.trials(i).jmp1.tOn < 0 || obj.trials(i).jmp1.nPats ~= 1 ||...
							size(obj.trials(i).jmp2,2) ~= 1 || obj.trials(i).jmp2.tOn >= 0 ||...
							isempty(obj.trials(i).iResponse1) )

							if( obj.trials(i).type == TRIAL_TYPE_DEF.CORRECT )
								obj.nCorrect = obj.nCorrect - 1;
								fprintf( 'Trial Index: %5d correct but unknown!\n', obj.trials(i).trialIndex );
							else
								obj.nError = obj.nError - 1;
								fprintf( 'Trial Index: %5d error but unknown!\n', obj.trials(i).trialIndex );
							end
							obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
							obj.nUnknown = obj.nUnknown + 1;
						else
							% fix the location of rf2
                            if( any( obj.trials(i).rf2.x == 0 ) )
                                obj.trials(i).rf2.x( obj.trials(i).rf2.x == 0 ) = - obj.trials(i).rf2.x( obj.trials(i).rf2.x ~= 0 );
                            end

							if( ~hasCue )	% no cue in the task
								obj.trials(i).cue.tOn = obj.trials(i).rf2.tOn;
								obj.trials(i).cue.tOff = obj.trials(i).rf2.tOn;
								obj.trials(i).cue.nPats = 1;
								obj.trials(i).cue.x = obj.trials(i).jmp1.x;
								obj.trials(i).cue.y = obj.trials(i).jmp1.y;
							end
						end						

					case TRIAL_TYPE_DEF.FIXBREAK
						[ tBreak, breakSac ] = obj.trials(i).GetBreak();
						if( size(obj.trials(i).fp,2) ~= 1 ||...
							size(obj.trials(i).rf,2) ~= 1 ||...
							size(obj.trials(i).rf2,2) ~= 1 ||...
							size(obj.trials(i).cue,2) ~= 1 ||...
							size(obj.trials(i).cue2,2) ~= 1 ||...
							size(obj.trials(i).jmp1,2) ~= 1 ||...
							size(obj.trials(i).jmp2,2) ~= 1 ||...
							tBreak < 0 || isempty(breakSac.latency) )

							obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
							obj.nFixbreak = obj.nFixbreak - 1;
							obj.nUnknown  = obj.nUnknown + 1;
							fprintf( 'Trial Index: %5d break but unknown!\n', obj.trials(i).trialIndex );
						else
							if( obj.trials(i).rf2.nPats == 2 )
								% fix rf2 location
                                if( any( obj.trials(i).rf2.x == 0 ) )
                                    obj.trials(i).rf2.x( obj.trials(i).rf2.x == 0 ) = - obj.trials(i).rf2.x( obj.trials(i).rf2.x ~= 0 );
                                end
							end
							if( ~hasCue )
								obj.trials(i).cue.tOn = obj.trials(i).rf2.tOn;
								obj.trials(i).cue.tOff = obj.trials(i).rf2.tOn;
								obj.trials(i).cue.nPats = min( [ 1, obj.trials(i).rf2.nPats ] );
								if( obj.trials(i).rf2.nPats == 2 )
									logic = obj.trials(i).rf2.red > obj.trials(i).rf2.red(2:-1:1);
									obj.trials(i).cue.x = obj.trials(i).rf2.x( logic );
									obj.trials(i).cue.y = obj.trials(i).rf2.y( logic );
								end
							end
						end

					case { TRIAL_TYPE_DEF.ABORT, TRIAL_TYPE_DEF.UNKNOWN }
						;

					otherwise
						obj.trials(i).type = TRIAL_TYPE_DEF.UNKNOWN;
						obj.nUnknown = obj.nUnknown + 1;
				end
			end
		end

		function RepeatDist( obj, newFigure )
			%% numbers of repeats after error and fixbreak

			if( nargin() == 1 )
				newFigure = false;
			end

			indices{2} = find( [obj.trials(1:end-1).type] == TRIAL_TYPE_DEF.FIXBREAK & [obj.trials(2:end).type] ~= TRIAL_TYPE_DEF.UNKNOWN );
			indices{1} = find( [obj.trials(1:end-1).type] == TRIAL_TYPE_DEF.ERROR & [obj.trials(2:end).type] ~= TRIAL_TYPE_DEF.UNKNOWN );
			for( i = 2 : -1 : 1 )
                if( ~isempty( indices{i} ) )
                    cue1 = [obj.trials(indices{i}).cue];
                    cue2 = [obj.trials(indices{i}+1).cue];
                    iLogical = [cue1.nPats] ~= 1 | [cue2.nPats] ~= 1;	% if no cue, the trial condition is undecidable
                    cue1(iLogical) = [];
                    cue2(iLogical) = [];
                    nRepeats(i).same = size( find( [cue1.x] == [cue2.x] & [cue1.y] == [cue2.y] & [cue1.green] == [cue2.green] ), 2 );
                    nRepeats(i).diff = size(cue1,2) - nRepeats(i).same;
                else
                    nRepeats(i).same = 0;
                    nRepeats(i).diff = 0;
                end
			end
			
			if( newFigure )
				figure;
			end
			hold on;
			set(gca,'xtick',[]);
			bar( 1, nRepeats(1).same, 0.5, 'b' );
			bar( 1.5, nRepeats(1).diff, 0.5, 'r' );
			text( 1.25, 0, 'error', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			bar( 2.5, nRepeats(2).same, 0.5, 'b' );
			bar( 3.0, nRepeats(2).diff, 0.5, 'r' );
			text( 2.75, 0, 'break', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			title( [ 'block ', obj.blockName ], 'interpreter', 'none' );
			if( newFigure )
				legend( 'same', 'diff' );
			end
			hold off;
		end

		function SRTDist( obj )	% distribution of saccades reaction time
			latency = zeros( 3, obj.nTrials ); % correct, error, fixbreak
			index = [ 0 0 0 ];
			tj1 = obj.GetTFromFp( REX_CODE_MAP.JMP1ON );
			for j = 1 : obj.nTrials
				if( obj.trials(j).type == TRIAL_TYPE_DEF.FIXBREAK && obj.trials(j).fp.tOn > 0 )	% break trial
					tmp = obj.trials(j).GetBreak() - obj.trials(j).fp.tOn - tj1;
					index(3) = index(3) + 1;
					latency(3,index(3)) = tmp;
				elseif( ~isempty( obj.trials(j).iResponse1 ) )
					tmp = obj.trials(j).saccades( obj.trials(j).iResponse1 ).latency...
							  - obj.trials(j).jmp1.tOn;
					if( obj.trials(j).type == TRIAL_TYPE_DEF.CORRECT )	% correct trial
						index(1) = index(1) + 1;
						latency(1,index(1)) = tmp;
					elseif( obj.trials(j).type == TRIAL_TYPE_DEF.ERROR )	% error trial
						index(2) = index(2) + 1;
						latency(2,index(2)) = tmp;
					end
                end
			end

			figure;
			hold on;
			set( gcf, 'NumberTitle', 'off', 'name', [ 'saccade_reaction_time_distribution_' obj.blockName ] );
			
			if( index(1) > 0 )
				hist( latency(1,1:index(1)), min(latency(1,1:index(1))) - 0.005 : 0.01 : max(latency(1,1:index(1))) + 0.005 );
			end
			if( index(2) > 0 )
				[data, ax] = hist( latency(2,1:index(2)), min(latency(2,1:index(2))) - 0.005 : 0.01 : max(latency(2,1:index(2))) + 0.005 );
				h = bar(ax,-data,1);
			end
			if( index(3) > 0 )
				hist( latency(3,1:index(3)), min(latency(3,1:index(3))) - 0.005 : 0.01 : max(latency(3,1:index(3))) + 0.005 );
			end

			hs = findobj(gca,'type','patch');
			try
				set( hs(2), 'LineStyle', 'none', 'FaceColor', 'g' );
				set( hs(3), 'LineStyle', 'none', 'FaceColor', 'r');
				set( hs(1), 'LineStyle', 'none', 'FaceColor', 'b', 'FaceAlpha', 0.7 );
				legend( hs([2,3,1]), 'correct', 'error', 'fixbreak' );
			catch exception
				disp( [ 'Exeption thrown in SRTDist() SCueBlock.m 191: ', exception.identifier ] );
				disp( [ 'Exception message: ', exception.message ] );
			end

			xlabel( 'latency' );
			ylabel( 'number of trials' );
		end

		function respLocs = Resp1LocDist( obj, newFigure )
			%% plot or return the location distribution of the first response saccade
			if( nargin() == 1 )
				newFigure = false;
            end
            respLocs = [];
			jmp1 = [ obj.trials.jmp1 ];
			jmp1( [ jmp1.nPats ] ~= 1 ) = [];
            if( isempty(jmp1) )
                return;
            end
			j1Cons = unique( [ jmp1.x ] * 1000 + [ jmp1.y ] );
			data = ones( 4, size(j1Cons,2), size(jmp1,2) ) * NaN; % first and second rows for x and y of start points while third and fourth for end points.
			count = ones( size(j1Cons,2), 1 );
			for( i = 1 : obj.nTrials )
				if( obj.trials(i).type ~= TRIAL_TYPE_DEF.CORRECT )
					continue;
				end
				iJ1Con = find( j1Cons == obj.trials(i).jmp1.x * 1000 + obj.trials(i).jmp1.y );
				data( :, iJ1Con, count(iJ1Con) ) = obj.trials(i).saccades( obj.trials(i).iResponse1 ).termiPoints( [ 1; 2; 3; 4 ] );
				count(iJ1Con) = count(iJ1Con) + 1;
			end
			average = nanmean( data, 3 );

			if( nargout() ~= 1 )
				x = reshape( data(1:2:end-1), 1, [] );
				xData( 3 : 3 : size(x,2)/2*3 ) = NaN;
				xData( 1 : 3 : size(x,2)/2*3-2 ) = x( 1 : 2 : end-1 );
				xData( 2 : 3 : size(x,2)/2*3-1 ) = x( 2 : 2 : end );
				y = reshape( data(2:2:end), 1, [] );
				yData( 3 : 3 : size(y,2)/2*3 ) = NaN;
				yData( 1 : 3 : size(y,2)/2*3-2 ) = y( 1 : 2 : end-1 );
				yData( 2 : 3 : size(y,2)/2*3-1 ) = y( 2 : 2 : end );				
				if( newFigure && nargout() ~= 1 )
					figure; hold on;
					set( gcf, 'NumberTitle', 'off', 'name', [ 'response1_location_distribution_' obj.blockName ] );
					plot( xData, yData, ':', 'color', [0.5,0.5,1] );
                end
                for( i = 1 : size(average,2) )
                    %plot( [ average([1 3]), NaN, average([5 7]) ], [ average([2 4]), NaN, average([6 8]) ], 'k:', 'marker', '*' );
                    plot( average( [1 3], i ), average( [2 4], i ), 'k:', 'marker', '*' );
                end
				axis('equal');
			else
				respLocs = average(:,:,1);
			end
		end

		function BreakDist( obj ) %%%%%% the codes could be improved with the new version of RefinedTrial.GetBreak()
            if( obj.nFixbreak == 0 )
                return;
            end
			iBreaks = find( [obj.trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
			count_t = ones(1,4);
			count_sac = ones(1,3);
			for( i = 3:-1:1 )
				data(i).tBreak = zeros(1,obj.nFixbreak);
				data(i).breakSac(obj.nFixbreak) = SaccadeTool.Saccade();
            end
			tCorrectBreaks = zeros(1,obj.nFixbreak);
			for( i = 1 : obj.nFixbreak )
				[tBreak, breakSac] = obj.trials(iBreaks(i)).GetBreak();

				% correct break saccades
				ep = breakSac.termiPoints(:,2);	% saccade end point
                win = 3;
				if( obj.trials(iBreaks(i)).cue.tOn > 0 && obj.trials(iBreaks(i)).rf.tOn > 0 && (...
					obj.trials(iBreaks(i)).cue.x > 0 && inpolygon( ep(1), ep(2), [10-win, 10+win, 10+win, 10-win], [win, win, -win, -win] ) ||...
					obj.trials(iBreaks(i)).cue.x < 0 && inpolygon( ep(1), ep(2), [-10-win, -10+win, -10+win, -10-win], [win, win, -win, -win] ) ) )
					tCorrectBreaks(count_t(4)) = tBreak - obj.trials(iBreaks(i)).rf.tOn;
					count_t(4) = count_t(4) + 1;
				end

				% aligned to rf, cue and rf2 respectively
				tOn = [ obj.trials(iBreaks(i)).rf.tOn, obj.trials(iBreaks(i)).cue.tOn, obj.trials(iBreaks(i)).rf2.tOn ];
				for( j = 1:3 )
					if( tOn(j) > 0 )
						data(j).tBreak(count_t(j)) = tBreak - tOn(j);
						count_t(j) = count_t(j) + 1;
						data(j).breakSac(count_sac(j)) = breakSac;
						count_sac(j) = count_sac(j) + 1;
					end
				end
            end

			for( i = 1 : 3 )
				data(i).tBreak = data(i).tBreak( 1 : count_t(i)-1 );
				data(i).breakSac = data(i).breakSac( 1 : count_sac(i)-1 );
			end
			tCorrectBreaks = tCorrectBreaks( 1 : count_t(4)-1 );

			nRows = 2;
			nColumns = 3;
			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Break_Distribution_', obj.blockName ] );
			set( gca, 'color', [0 0 0] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
			jf.setMaximized(1);
			
			% draw time and direction distributions
			titles = { 'rf', 'cue', 'rf2' };
			for( i = 1 : 3 )
                if( isempty( data(i).tBreak ) || isempty( data(i).breakSac ) ), continue; end
				subplot( nRows, nColumns, i ); hold on;
                hist( data(i).tBreak, min( data(i).tBreak ) - 0.005*MK_CONSTANTS.TIME_UNIT : 0.01*MK_CONSTANTS.TIME_UNIT : max( data(i).tBreak ) + 0.005*MK_CONSTANTS.TIME_UNIT );
				xlabel('time(s)'); ylabel('number of trials');
				set( findobj(gca,'type','patch'), 'LineStyle', 'none' );
				title( [ 'aligned to ', titles{i}, ' on' ] );
				
				subplot( nRows, nColumns, i+3 );
				hist( [data(i).breakSac.angle], min( [data(i).breakSac.angle] ) - 5 : 10 : max( [data(i).breakSac.angle] ) + 5 );
				xlabel( 'angle(\circ)' ); ylabel('number of trials');
				set( findobj(gca,'type','patch'), 'LineStyle', 'none' );
				title( [ 'break direction after ', titles{i}, ' on' ] );
			end
			
			subplot( nRows, nColumns, 1 );
			
			% draw correct breaks distribution
            if( ~isempty(tCorrectBreaks) )
                hist( tCorrectBreaks, min(data(1).tBreak) - 0.005*MK_CONSTANTS.TIME_UNIT : 0.01*MK_CONSTANTS.TIME_UNIT : max(data(1).tBreak) + 0.005*MK_CONSTANTS.TIME_UNIT );
                h = findobj( gca, 'type', 'patch' );
                set( h(1), 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.6 );
                legend( h, sprintf('crct brk(%d)',win), 'break', 'location', 'west' );
            end

            % draw lines
			y = get(gca,'ylim');			
			x = [ obj.GetTFromFp(REX_CODE_MAP.CUEON) - obj.GetTFromFp(REX_CODE_MAP.RFON),...
				  obj.GetTFromFp(REX_CODE_MAP.RF2ON) - obj.GetTFromFp(REX_CODE_MAP.RFON),...
				  obj.GetTFromFp(REX_CODE_MAP.JMP1ON) - obj.GetTFromFp(REX_CODE_MAP.RFON) ];
			txts = { 'cue(', 'rf2(', 'jmp1(' };
			colors = [ 0, 0.7, 0; 0.7, 0, 0; 0.7, 0.7, 0 ];
			for( i = 1 : 3 )
				plot( ones(1,2) * x(i), [ y(1), y(2)-0.5*i ], 'color', colors(i,:) );
				text( x(i), y(2)-0.5*i, [ txts{i}, sprintf('%.3f',x(i)), ')' ], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom' );
			end
		end

		function PlotRfLoc( obj, newFigure, tag )
			if nargin == 1
				newFigure = true;
				tag = '';
			elseif nargin == 2
				tag = '';
			elseif nargin ~= 3
				disp('Usage: obj.PlotRfLoc( [newFigure==true, tag='''' )');
				return;
			end
			
			rf = [ obj.trials.rf ];
			rf( [rf.nPats] ~= 2 ) = [];
			x = [rf.x];
			y = [rf.y];

			if newFigure
				figure; hold on;
			end
			plot( x, y, 'b.', 'tag', tag );
		end

		function angles = GetCueAngles( obj )
			angles = [];
			if isempty( obj.trials )
				return;
			end
			cue = [ obj.trials.cue ];
			cue( [ cue.nPats ] == 0 ) = [];
			% if isempty( cue )
			% 	angles = [ 0, 180 ];
			% 	return;
			% end
			angles = cart2pol( [ cue.x ], [ cue.y ] );
			angles = unique( angles ) / pi * 180;
		end

		function CueDist( obj )
			%% directions and colors distributions of cue
			figure;
			cue = [obj.trials.cue];
			cue( [cue.nPats] == 0 ) = [];
			if isempty(cue)
				return;
			end
			subplot(1,2,1);
			angles = cart2pol( [cue.x], [cue.y] ) / pi * 180;
			hist(angles, 180);
			title('Cue Direction');

			%% cue color
			subplot(1,2,2);
			hist( [cue.green], 0:255 );
			title('Cue Color');
		end

		function Rf2Dist( obj )
			%% directions and colors distributions of rf2
			figure;
			rf2 = [obj.trials.rf2];
			rf2( [rf2.nPats] == 0 ) = [];
			if isempty(rf2)
				return;
			end
			hist( [rf2.red], 0:255 );
			title('Rf2 Color');
		end


	end

end