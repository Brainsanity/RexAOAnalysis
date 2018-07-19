classdef SCueBlocksAnalyzer < BlocksAnalyzer

	properties
		nSaccades;
		cueConditions;
		nConTrials;
		tRf = -0.01;	% mean rf on time across blocks
		tCue = -0.01;	% mean cue on time across blocks
		tRf2 = -0.01;	% mean rf2 on time across blocks
		tJmp1 = -0.01;	% mean jmp1 on time across blocks
	end

	methods
		%% SCueBlocksAnalyzer: constructor of class SCueBlocksAnalyzer
		function obj = SCueBlocksAnalyzer( fileNames, fieldFlags )
			if( nargin() == 0 )
				fileNames = [];
			end
			if( nargin() == 1 )
				fieldFlags = DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX;
			end

			obj = obj@BlocksAnalyzer( 'SCueBlock', fileNames, fieldFlags );
			
		end

		function ShowTask( obj, path, iFirst, iLast )	% iFirst for index of the first block; iLast for the last one
			if nargin == 1
				path = [];
				iFirst = 1;
				iLast = obj.nBlocks;
			elseif nargin ==2
				iFirst = 1;
				iLast = obj.nBlocks;
			elseif nargin == 3
				if iFirst < 1
					iFirst = 1;
				elseif iFirst > obj.nBlocks
					iFirst = obj.nBlocks;
				end						
				iLast = obj.nBlocks;
			elseif nargin == 4
				if iFirst < 1
					iFirst = 1;
				elseif iFirst > obj.nBlocks
					iFirst = obj.nBlocks;
				end
				if iLast < 1
					iLast = 1;
				elseif iLast > obj.nBlocks
					iLast = obj.nBlocks;
				end
			else
				disp('Usage: obj.BreakDist( [ path=[], iFirst=1, iLast=obj.nBlocks ] )');
			end

			%% plot time line
			figure;
			tit = [ 'Task_blocks[' ];
			for( i = iFirst : iLast )
				tit = [ tit, obj.blocks(i).blockName, ',' ];
			end
			if( tit(end) == ',' )
				tit(end) = ']';
			else
				tit(end+1) = ']';
			end
			set( gcf, 'NumberTitle', 'off', 'Name', tit );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
			subplot(2,2,1); hold on;
			title('Time Line');

			nTrials = zeros( 1, iLast-iFirst+1 );
			t		= zeros( 4, iLast-iFirst+1 );
			for i = iFirst : iLast
				obj.blocks(i).ShowTimeLine( false );
				nTrials(i)	= obj.blocks(i).nTrials;
				t(1,i)		= obj.blocks(i).GetTFromFp(REX_CODE_MAP.RFON);
				t(2,i)		= obj.blocks(i).GetTFromFp(REX_CODE_MAP.CUEON);
				t(3,i)		= obj.blocks(i).GetTFromFp(REX_CODE_MAP.RF2ON);
				t(4,i)		= obj.blocks(i).GetTFromFp(REX_CODE_MAP.JMP1ON);
			end
			t = sum( t .* repmat( nTrials, 4, 1 ), 2 ) / sum(nTrials);
			h = [];
			colors = 'bgry';
			names  = { 'rf', 'cue', 'rf2', 'jmp1' };
            hold on;
			for( i = 1 : 4 )
				if( t(i) > 0 )
					h = [ h, plot( ones(1,2) * t(i), get(gca,'ylim'), colors(i), 'DisplayName', names{i} ) ];
				end
			end
			if ~isempty(h)
				legend( h, 'location', 'NorthEast' );
            end
            hold off;

			%% calculation
			cue = [];
			rf2 = [];
			for i = iFirst: iLast
				cue = [ cue, obj.blocks(i).trials.cue ];
				rf2 = [ rf2, obj.blocks(i).trials.rf2 ];
			end
			cue( [ cue.nPats ] == 0 ) = [];
			rf2( [ rf2.nPats ] == 0 ) = [];
			angles = cart2pol( [cue.x], [cue.y] ) / pi * 180;

			%% plot cue direction
			subplot(2,2,2);
			hist(angles, 180);
			title('Cue Direction');

			%% plot cue color
			subplot(2,2,3);
			hist( [cue.green], 0:255 );
			title('Cue Color');

			%% plot rf2 color
			subplot(2,2,4);
			hist( [rf2.red], 0:255 );
			title('Rf2 Color');

			%% show summation data
			n = size( num2str( sum( [obj.blocks(iFirst:iLast).nTrials] ) ), 2 );
			nCorrect = num2str( sum( [ obj.blocks(iFirst:iLast).nCorrect ] ) );
			nCorrect( end+1 : end + 2 * ( n - size(nCorrect,2) ) ) = ' ';
			nError = num2str( sum( [ obj.blocks(iFirst:iLast).nError ] ) );
			nError( end+1 : end + 2 * ( n - size(nError,2) ) ) = ' ';
			nFixbreak = num2str( sum( [ obj.blocks(iFirst:iLast).nFixbreak ] ) );
			nFixbreak( end+1 : end + 2 * ( n - size(nFixbreak,2) ) ) = ' ';
			ToolKit.BorderText( 'figurecenter', [ '  nCorrect: ', nCorrect, '\n', '      nError: ', nError, '\n', 'nFixbreak: ', nFixbreak ], 'FontSize', 8 );

			if ~isempty(path)
				if path(end) ~= '\' && path(end) ~= '/'
					path(end+1) = '/';
				end
				if exist( path, 'dir' ) ~= 7
					mkdir( path );
				end
				filename = get(gcf,'Name');
				if( size(filename,2) > 124 ), filename = [ 'Task_blocks[', num2str(iFirst), ',', num2str(iLast), ']' ]; end
				saveas( gcf, [ path, filename, '.fig' ] );
				saveas( gcf, [ path, filename, '.bmp' ] );
			end
		end

		function PlotRfLoc( obj )
			figure; hold on;
			for i = 1 : obj.nBlocks
				obj.blocks(i).PlotRfLoc( false, [ 'block_', num2str(i) ] );
			end
		end

		function BreakDist( obj, iFirst, iLast, groupEdges, timeEdges, dist_step, t_step, path )
			%% iFirst:		index of the first block to analyze
			%  iLast:		for the last block to analyze
			%  gropuEdges:	edges to group cue conditions( range of [-180, 180] )
			%  timeEdges:	cell array containing edges to seperate trials along the time course
			%					1st cell for time bins after cue on
			%					2nd cell for time bins after cue off
			%					3rd cell for time bins after rf2 on
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 || isempty(groupEdges) )
				groupEdges = [-180,181];
			end
			if( nargin() <= 4 || isempty(timeEdges) || ~iscell(timeEdges) )
				timeEdges = { [0.05,0.25]*MK_CONSTANTS.TIME_UNIT, [0.05,0.25]*MK_CONSTANTS.TIME_UNIT, [0.05,0.25]*MK_CONSTANTS.TIME_UNIT };
			end
			if( nargin() <= 5 || dist_step < 0 )
				dist_step = 0.5;
			end
			if( nargin() <= 6 || t_step < 0 )
				t_step = 0.01 * MK_CONSTANTS.TIME_UNIT;
			end
			if( nargin() <= 7 )
				path = [];
			end

			if( iFirst > iLast )
				return;
			elseif( iFirst < 1 )
				iFirst = 1;
			elseif( iFirst > obj.nBlocks )
				iFirst = obj.nBlocks;
			end
			if( iLast < 1 )
				iLast = 1;
			elseif( iLast > obj.nBlocks )
				iLast = obj.nBlocks;
			end

			if( isempty( timeEdges{1} ) )
				timeEdges{1} = [0,0];
			end
			if( size(timeEdges,2) <= 1 || isempty( timeEdges{2} ) )
				timeEdges{2} = [0,0];
			end
			if( size(timeEdges,2) <= 2 || isempty( timeEdges{3} ) )
				timeEdges{3} = [0,0];
			end

			nCueGroups = size(groupEdges,2) - 1;
			if( nCueGroups <= 0 )
				disp('Usage: obj.BreakDist( [ iFirst=1, iFirst=end, groupEdges=[-180,180], path=[] ] )');
				fprintf('\tgroupEdges: a vector containing edges to group cue conditions; its size should be larger than 1.');
				return;
			end

			nTimeBins(3) = size( timeEdges{3}, 2 ) - 1;
			nTimeBins(2) = size( timeEdges{2}, 2 ) - 1;
			nTimeBins(1) = size( timeEdges{1}, 2 ) - 1;

			%% initialize data
			tBreak.t = zeros( nCueGroups, obj.nFixbreak, 3 );	% data for break time distribution
				% 1st page for breaks after rf on
				% 2nd page for breaks after cue on
				% 3rd page for breaks after rf2 on
			tBreak.cnt = zeros( nCueGroups, 3 );				% counter
			data{3}( nCueGroups, max([1,obj.nError]) ) = RefinedTrial();						% data for error trials
			data{2}( nCueGroups, max([1,obj.nFixbreak]), sum(nTimeBins) ) = RefinedTrial();	% data for breaks after cue on
				% 1st dimension: index of cue groups
				% 2nd dimension: index of break saccade
				% 3rd dimension: index of time bins
			data{1}(obj.nFixbreak) = RefinedTrial();								% data for breaks before cue on and after rf on
			count{3} = zeros( nCueGroups, 1 );										% counter for error data
			count{2} = zeros( nCueGroups, sum(nTimeBins) );							% counter for breaks after cue on
			count{1} = 0;															% counter for breaks before cue on and after rf on
			
			%% collect data
			for( iBlock = iFirst : iLast )
				% get all break trials whoes previous trials are correct trials
				trials = obj.blocks(iBlock).trials( [ obj.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.FIXBREAK);% &...
													%[ TRIAL_TYPE_DEF.CORRECT, obj.blocks(iBlock).trials(1:end-1).type ] == TRIAL_TYPE_DEF.CORRECT );
				if( isempty(trials) ), continue; end
                rf = [ trials.rf ];
				trials( [rf.tOn] < 0 ) = [];
                if( isempty(trials) ), continue; end

				% get trials breaking before cue on
				% NOTICE: such break trials have nothing to do with cue conditions
				cue = [ trials.cue ];
                if( ~isempty(cue) )
                    tmp = trials( [cue.tOn] < 0 );
                    n = count{1} + size(tmp,2);
                    data{1}( count{1}+1 : n ) = tmp;
                    count{1} = n;
                end

				% get trials breaking after cue on
				tmp = trials( [cue.tOn] > 0 );
				for( trial = tmp )
					ang = cart2pol( trial.cue.x, trial.cue.y ) / pi * 180;
					iCueGroup = find( groupEdges(1:end-1) <= ang & ang < groupEdges(2:end), 1, 'first' );

					% get data for time distribution
					tBases = [ trial.rf.tOn, trial.cue.tOn, trial.rf2.tOn ];
					for( i = 1 : 3 )
						if( tBases(i) > 0 )
							tBreak.cnt(iCueGroup,i) = tBreak.cnt(iCueGroup,i) + 1;
							tBreak.t( iCueGroup, tBreak.cnt(iCueGroup,i), i ) = trial.GetBreak() - tBases(i);
						end
					end

					% get data for distance distribution
					tBases = [ trial.cue.tOn, trial.cue.tOff, trial.rf2.tOn ];
					for( i = 1 : 3 )
						if( tBases(i) > 0 )
							t = trial.GetBreak() - tBases(i);
							iTimeBin = sum( nTimeBins(1:i-1) ) + find( timeEdges{i}(1:end-1) <= t & t < timeEdges{i}(2:end), 1, 'first' );
							count{2}(iCueGroup,iTimeBin) = count{2}(iCueGroup,iTimeBin) + 1;
							data{2}( iCueGroup, count{2}(iCueGroup,iTimeBin), iTimeBin ) = trial;
						end
					end
				end

				% get error trials
				trials = obj.blocks(iBlock).trials( [ obj.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.ERROR );
				cue = [ trials.cue ];
                if( ~isempty(cue) )
                    ang = cart2pol( [cue.x], [cue.y] ) / pi * 180;
                    for( iCueGroup = 1 : nCueGroups )
                        tmp = trials( ang >= groupEdges(iCueGroup) & ang < groupEdges(iCueGroup+1) );
                        if( isempty(tmp) ), continue; end
                        n = count{3}(iCueGroup) + size(tmp,2);
                        data{3}( iCueGroup, count{3}(iCueGroup)+1 : n ) = tmp;
                        count{3}(iCueGroup) = n;
                    end
                end
			end

			%% draw figures			
			for( iCueGroup = 1 : nCueGroups )
				figure;
				tit = [ 'BreakDist_cue[', num2str(groupEdges(iCueGroup)), ',', num2str(groupEdges(iCueGroup+1)), ']_blocks[' ];
				for( i = iFirst : iLast )
					tit = [ tit, obj.blocks(i).blockName, ',' ];
				end
				if( tit(end) == ',' )
					tit(end) = ']';
				else
					tit(end+1) = ']';
				end
				set( gcf, 'NumberTitle', 'off', 'Name', tit );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
				nRows	 = 3;
				nColumns = sum(nTimeBins) + 3;

				%% for time distribution
                if( count{1} > 0 )
                    rf = [data{1}.rf];
                    tBreak.t( iCueGroup, tBreak.cnt(iCueGroup,1)+1 : tBreak.cnt(iCueGroup,1) + count{1}, 1 ) = data{1}(1:count{1}).GetBreak() - [rf.tOn];
                    tBreak.cnt(iCueGroup,1) = tBreak.cnt(iCueGroup,1) + count{1};
                end
				titles = { 'rf on', 'cue on', 'rf2 on' };
				for( i = 1 : 3 )
					subplot( nRows, nColumns, 1 + nColumns*(i-1) );
					t = tBreak.t( iCueGroup, 1 : tBreak.cnt(iCueGroup,i), i );
                    if( isempty(t) )
                        continue;
                    end
	            	[ n, ax ] = hist( t, min(t) - t_step/2 : t_step : max(t) + t_step/2 );
	            	set( gca, 'xlim', [ min(t) - t_step, max(t) + t_step ], 'xtick', 0 : 0.1 : max(t)+t_step );
	            	bar( ax, n/sum(n) );
	            	title( [ 'aligned to ', titles{i} ] );
	            	xlabel( 'break time' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', tBreak.cnt(iCueGroup,i) ) );
	            end

	            %% for breaks before cue on
	            trials = data{1}(1:count{1});
                if( ~isempty(trials) )
                    [ ~, sacs ] = trials.GetBreak();
                    endPoints = [sacs.termiPoints];
                else
                    endPoints = [];
                end
	        	
	        	subplot( nRows, nColumns, 2 ); hold on;
                if( ~isempty(endPoints) )
                    dists = sqrt( ( endPoints( 1, 2:2:end ) - 10 ).^2 + ( endPoints( 2, 2:2:end ) ).^2 );
                    [ n, ax ] = hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                    bar( ax, n/sum(n) );
                    set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                    fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                    title( 'rf on to cue on' );
                    xlabel( 'distance from right (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{1} ) );
                end

	        	subplot( nRows, nColumns, nColumns + 2 ); hold on;
                if( ~isempty(endPoints) )
                    dists = sqrt( ( endPoints( 1, 2:2:end ) + 10 ).^2 + ( endPoints( 2, 2:2:end ) ).^2 );
                    [ n ,ax ] = hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                    bar( ax, n/sum(n) );
                    set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                    fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                    title( [ 'rf on to cue on' ] );
                    xlabel( 'distance from left (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{1} ) );
                end

	        	subplot( nRows, nColumns, nColumns*2 + 2 ); hold on;
            	axis('equal');
            	%	plot saccade start and end points
                if( ~isempty(trials) )
                    n = size(trials,2) * 3;
                    points = zeros( 2, n ) * NaN;
                    points( :, 1 : 3 : n - 2 ) = endPoints( :, 1:2:end-1 );
                    points( :, 2 : 3 : n - 1 ) = endPoints( :, 2:2:end );
                    plot( points(1,:), points(2,:), 'c:' );
                    plot( endPoints( 1, 1:2:end-1 ), endPoints( 2, 1:2:end-1 ), 'c.' );
                    plot( endPoints( 1, 2:2:end ), endPoints( 2, 2:2:end ), 'r.' );
                    for( iBlock = iFirst : iLast )
                        obj.blocks(iBlock).Resp1LocDist(false);
                    end
                    xlabel( 'Horizontal (\circ)' ); ylabel( 'Vertical (\circ)' );
                end
            	
            	%% for breaks after cue on
            	titlePre = { 'cue on', 'cue off', 'rf2 on' };
	            for( i = 1 : 3 )
	            	for( j = 1 : nTimeBins(i) )
	            		iTimeBin = sum( nTimeBins(1:i-1) ) + j;
	            		trials = data{2}( iCueGroup, 1:count{2}(iCueGroup,iTimeBin), iTimeBin );

	            		% get break saccades end points
                        if( ~isempty(trials) )
                            [ ~, sacs ] = trials.GetBreak();
                            endPoints = [sacs.termiPoints];
                            clear sacs;
                        else
                            endPoints = [];
                        end

		            	% plot distance from break saccade end point to cue
		            	subplot( nRows, nColumns, iTimeBin + 2 ); hold on;
                        if( ~isempty(endPoints) )
                            cue = [trials.cue];
                            dists = sqrt( ( endPoints( 1, 2:2:end ) - [cue.x] ).^2 + ( endPoints( 2, 2:2:end ) - [cue.y] ).^2 );
                            [ n, ax ]= hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                            bar( ax, n/sum(n) );         	
                            set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                            fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                            title( [ titlePre{i}, ' + [ ', num2str(timeEdges{i}(j)), ' : ', num2str(timeEdges{i}(j+1)), ' ] (s)' ] );
                            xlabel( 'distance from cue (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{2}(iCueGroup,iTimeBin) ) );
                        end

		            	% plot distance from break saccade end point to target
		            	subplot( nRows, nColumns, nColumns + iTimeBin + 2 ); hold on;
                        if( ~isempty(endPoints) )
                            targets = zeros( 2, size(trials,2) );
                            targets( 1, [cue.x] > 0 ) = 10;
                            targets( 1, [cue.x] < 0 ) = -10;
                            dists = sqrt( ( endPoints( 1, 2:2:end ) - targets(1,:) ).^2 + ( endPoints( 2, 2:2:end ) - targets(2,:) ).^2 );
                            [ n, ax ] = hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                            bar( ax, n/sum(n) );
                            set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                            fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                            title( [ titlePre{i}, ' + [ ', num2str(timeEdges{i}(j)), ' : ', num2str(timeEdges{i}(j+1)), ' ] (s)' ] );
                            xlabel( 'distance from target (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{2}(iCueGroup,iTimeBin) ) );
                        end

		            	% show break start and end points
		            	subplot( nRows, nColumns, nColumns*2 + iTimeBin + 2 ); hold on;
		            	axis('equal');
		            	%	plot saccade start and end points
                        if( ~isempty(trials) )
                            n = size(trials,2) * 3;
                            points = zeros( 2, n ) * NaN;
                            points( :, 1 : 3 : n - 2 ) = endPoints( :, 1:2:end-1 );
                            points( :, 2 : 3 : n - 1 ) = endPoints( :, 2:2:end );
                            plot( points(1,:), points(2,:), 'r' );% 'c:' );
                            plot( endPoints( 1, 1:2:end-1 ), endPoints( 2, 1:2:end-1 ), 'c.' );
                            plot( endPoints( 1, 2:2:end ), endPoints( 2, 2:2:end ), 'r.' );
                            %	plot cue
                            cue = unique( [ cue.x; cue.y ]', 'rows' )';
                            plot( cue(1,:), cue(2,:), 'g.' );
                            plot( [ 0 cue(1,end) ], [ 0 cue(2,end) ], 'g:' );
                            for( iBlock = iFirst : iLast )
                                obj.blocks(iBlock).Resp1LocDist(false);
                            end
                            xlabel( 'Horizontal (\circ)' ); ylabel( 'Vertical (\circ)' );
                        end
		            end
	        	end

	        	%% for error trials
	        	trials = data{3}( iCueGroup, 1:count{3}(iCueGroup) );
                if( ~isempty(trials) )
                    clear sacs;
                    sacs(count{3}(iCueGroup)) = SaccadeTool.Saccade();
                    for( iTrial = 1 : size(trials,2) )
                        sacs(iTrial) = trials(iTrial).saccades( trials(iTrial).iResponse1 );
                    end
                    endPoints = [sacs.termiPoints];
                else
                    endPoints = [];
                end
	        	% plot distance from error saccade end point to cue
	        	subplot( nRows, nColumns, nColumns ); hold on;
                if( ~isempty(endPoints) )
                    cue = [trials.cue];
                    dists = sqrt( ( endPoints( 1, 2:2:end ) + [cue.x] ).^2 + ( endPoints( 2, 2:2:end ) - [cue.y] ).^2 );	% opposite to cue
                    [ n, ax ]= hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                    bar( ax, n/sum(n) );         	
                    set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                    fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                    title( 'error trials' );
                    xlabel( 'distance from opposite cue (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{3}(iCueGroup) ) );
                end

            	% plot distance from error saccade end point to target
            	subplot( nRows, nColumns, nColumns * 2 ); hold on;
                if( ~isempty(endPoints) )
                    targets = zeros( 2, size(trials,2) );
                    targets( 1, [cue.x] > 0 ) = 10;
                    targets( 1, [cue.x] < 0 ) = -10;
                    dists = sqrt( ( endPoints( 1, 2:2:end ) + targets(1,:) ).^2 + ( endPoints( 2, 2:2:end ) - targets(2,:) ).^2 );	% opposite to target
                    [ n, ax ] = hist( dists, min(dists) - dist_step/2 : dist_step : max(dists) + dist_step/2 );
                    bar( ax, n/sum(n) );
                    set( gca, 'xlim', [0,40], 'xtick', 0:5:40, 'ylim', [0,1] );
                    fill( [ 0, 0, 5, 5, 0 ], [ 0, 1, 1, 0, 0 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
                    title( 'error trials' );
                    xlabel( 'distance from opposite target (\circ)' ); ylabel( sprintf( 'Proportions(%%) of %d Trials', count{3}(iCueGroup) ) );
                end

            	% show error start and end points
            	subplot( nRows, nColumns, nColumns * 3 ); hold on;
            	axis('equal');
            	%	plot saccade start and end points
                if( ~isempty(endPoints) )
                    n = size(trials,2) * 3;
                    points = zeros( 2, n ) * NaN;
                    points( :, 1 : 3 : n - 2 ) = endPoints( :, 1:2:end-1 );
                    points( :, 2 : 3 : n - 1 ) = endPoints( :, 2:2:end );
                    plot( points(1,:), points(2,:), 'c:' );
                    plot( endPoints( 1, 1:2:end-1 ), endPoints( 2, 1:2:end-1 ), 'c.' );
                    plot( endPoints( 1, 2:2:end ), endPoints( 2, 2:2:end ), 'r.' );
                    %	plot cue
                    cue = unique( [ cue.x; cue.y ]', 'rows' )';
                    plot( cue(1,:), cue(2,:), 'g.' );
                    plot( [ 0 cue(1,end) ], [ 0 cue(2,end) ], 'g:' );
                    for( iBlock = iFirst : iLast )
                        obj.blocks(iBlock).Resp1LocDist(false);
                    end
                    xlabel( 'Horizontal (\circ)' ); ylabel( 'Vertical (\circ)' );
                end


	        	set( findobj( 'type', 'patch' ), 'LineStyle', 'none' );
	        end

		end

		function BreakDistV1( path )
			
			cueConditions = [];
			for i = iFirst : iLast
				cueConditions = unique( [ cueConditions, obj.blocks(i).GetCueAngles() ] );
			end

			if nCueGroups == -1
				cueGroups = cell(1,1);
				cueGroups{1} = cueConditions;
			else
				cueGroups = cell( size(cueConditions,2), 1 );
				for i = 1 : size( cueConditions, 2 )
					cueGroups{i} = cueConditions(i);
				end
			end

			for iGroup = 1 : size( cueGroups, 1 )
				data = cell(1,9);
				for i = 1 : 3
					data{i} = ones( 1, obj.nTrials ) * NaN;
				end
				for i = 4 : 6
					data{i} = ones( 3, obj.nTrials ) * NaN;
				end
				for i = 7 : 9
					data{i} = ones( 2, obj.nTrials * 3 ) * NaN;
				end
				count = ones(1,9);

				cue = [];
				for i = iFirst : iLast
					respAng = obj.blocks(i).ResponseLocDist();				
					%respAng = cart2pol( respAng(3,:), respAng(4,:) ) / pi * 180;
					respAng = cart2pol( respAng(3,:) - respAng(1,:), respAng(4,:) - respAng(2,:) ) / pi * 180;
					if cos( respAng(1) / 180 * pi ) < 0
						respAng = respAng([2,1]);
					end

					for j = 1 : obj.blocks(i).nTrials
						if strcmp( obj.blocks(i).trials(j).trialType, TRIAL_TYPE_DEF.FIXBREAK ) && ( j == 1 || strcmp( obj.blocks(i).trials(j-1).trialType, TRIAL_TYPE_DEF.CORRECT ) )
							tBreak = obj.blocks(i).trials(j).eventCodes( 1, obj.blocks(i).trials(j).eventCodes(2,:) == CODE_DEF.FIXBREAK );
							if size(tBreak,2) ~= 1
								continue;
							end
							cueAng = cart2pol( obj.blocks(i).trials(j).cue.x, obj.blocks(i).trials(j).cue.y ) / pi * 180;
							if isempty(cueAng) || isempty( find( cueGroups{iGroup} == cueAng, 1 ) )
								continue;
                            end

							if obj.blocks(i).trials(j).rf.tOn > 0
								data{1}(count(1)) = tBreak - obj.blocks(i).trials(j).rf.tOn;
								count(1) = count(1) + 1;
							end
							if obj.blocks(i).trials(j).cue.tOn > 0
								data{2}(count(2)) = tBreak - obj.blocks(i).trials(j).cue.tOn;
								count(2) = count(2) + 1;
							end
							if obj.blocks(i).trials(j).rf2.tOn > 0
								data{3}(count(3)) = tBreak - obj.blocks(i).trials(j).rf2.tOn;
								count(3) = count(3) + 1;
                            end

							if ~isempty( obj.blocks(i).trials(j).saccades )                                
								if obj.blocks(i).trials(j).cue.x ~= 0 && obj.blocks(i).trials(j).cue.y ~= 0
									cue = unique( [ cue, ( obj.blocks(i).trials(j).cue.x + 250 ) * 10000 + ( obj.blocks(i).trials(j).cue.y + 250 ) ] );
								end
                                breakSac = obj.blocks(i).trials(j).saccades;
                                breakSac = breakSac( find( [breakSac.latency] < tBreak + 0.05 & [breakSac.latency] > tBreak - 0.1, 1 ) );
                                if size(breakSac,2) ~= 1
                                	continue;
                                end
	                            breakPoint = breakSac.termiPoints;
	                            %breakAng = cart2pol( breakPoint(1,2), breakPoint(2,2) ) / pi * 180 - [ respAng, cueAng ];
	                            breakAng = breakSac.angle - [ respAng, cueAng ];
	                            index = breakAng > 180;
	                            breakAng(index) = breakAng(index) - 360;
	                            index = breakAng <= -180;
	                            breakAng(index) = breakAng(index) + 360;
								if obj.blocks(i).trials(j).cue.tOn > 0 && tBreak > obj.blocks(i).trials(j).cue.tOn + 0.05 && tBreak < obj.blocks(i).trials(j).cue.tOn + 0.2
									data{4}( :, count(4) ) = breakAng';
									count(4) = count(4) + 1;
									data{7}( :, count(7) : count(7) + 2 ) = [ breakSac.termiPoints, [NaN; NaN] ];
									count(7) = count(7) + 3;
								end
								if obj.blocks(i).trials(j).cue.tOff > 0 && tBreak > obj.blocks(i).trials(j).cue.tOff && tBreak < obj.blocks(i).trials(j).cue.tOff + 0.2
								%if obj.blocks(i).trials(j).rf.tOn > 0 && tBreak > obj.blocks(i).trials(j).rf.tOn && tBreak < obj.blocks(i).trials(j).rf.tOn + 0.2
									data{5}( :, count(5) ) = breakAng';
									count(5) = count(5) + 1;
									data{8}( :, count(8) : count(8) + 2 ) = [ breakSac.termiPoints, [NaN; NaN] ];
									count(8) = count(8) + 3;
								end
								if obj.blocks(i).trials(j).rf2.tOn > 0 && tBreak > obj.blocks(i).trials(j).rf2.tOn % && tBreak < obj.blocks(i).trials(j).rf2.tOn + 0.1
									data{6}( :, count(6) ) = breakAng';
									count(6) = count(6) + 1;
									data{9}( :, count(9) : count(9) + 2 ) = [ breakSac.termiPoints, [NaN; NaN] ];
									count(9) = count(9) + 3;
                                end
							end
                        end
					end
				end

				nRows = 3;
				nColumns = 5;
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', [ 'block', num2str(iFirst), '-', num2str(iLast), '_Break_Distribution_iGroup', num2str(iGroup) ] );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
				for i = 1 : nRows * nColumns
					subplot( nRows, nColumns, mod(i-1,nRows) * nColumns + ceil(i/nRows) ); hold on;
					if ( i<=3 && ~isempty( data{i} ) ) || ~isempty( data{ 4 + mod(i-4,3) } )
						if i <= 3
							if ~isempty( data{i} )
								hist( data{i}, min(data{i}) - 0.05 : 0.01 : max(data{i}) + 0.05 );
								set( findobj( gca, 'Type', 'Patch'), 'LineStyle', 'none' );
							end
	                    elseif i <= 12
							[ n ax ] = hist( data{ 4 + mod(i-4,3) }( ceil( (i-3)/3 ), : ), -180 : 5 : 180 );
							n = n / sum(n);
							bar(ax,n,1);
							set( findobj( gca, 'Type', 'Patch' ), 'EdgeColor', 'w' );
							set( gca, 'xtick', -180:45:180, 'ylim', [0 1] );
							y = get( gca, 'ylim' );
							fill( [ -10, -10, 10, 10, -10 ], [ y(1), y(2), y(2), y(1), y(1) ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.4 );
						else
							if showResponseLoc
								for nBlock = iFirst : iLast	
									obj.blocks(nBlock).ResponseLocDist();
								end
							end
							plot( data{i-6}(1,:), data{i-6}(2,:), 'c:' ); axis equal;
							plot( data{i-6}(1,1:3:end-2), data{i-6}(2,1:3:end-2), 'c.' );
							plot( data{i-6}(1,2:3:end-1), data{i-6}(2,2:3:end-1), 'r.' );
							plot( fix(cue/10000) - 250, mod(cue,1000) - 250, 'g.' );
							if ~showResponseLoc
								for nBlock = iFirst : iLast
									loc = obj.blocks(nBlock).ResponseLocDist();
									plot( loc( 1 : 2 : end -1 ), loc( 2 : 2 : end ), 'k*' );
								end
							end
						end
						switch i
							case 1
								title('aligned to rf on');
							case 2
								title('aligned to cue on');
							case 3
								title('aligned to rf2 on');
							case 4
								title('break direct after cue on (aligned2 right)');
							case 5
								title('break direct after cue off (aligned2 right)');
							case 6
								title('break direct after rf2 on (aligned2 right)');
							case 7
								title('break direct after cue on (aligned2 left)');
							case 8
								title('break direct after cue off (aligned2 left)');
							case 9
								title('break direct after rf2 on (aligned2 left)');
							case 10
								title('break direct after cue on (aligned2 cue)');
							case 11
								title('break direct after cue off (aligned2 cue)');
							case 12
								title('break direct after rf2 on (aligned2 cue)');
						end
					end
				end

				if ~isempty(path)
					if path(end) ~= '\' && path(end) ~= '/'
						path(end+1) = '/';
					end
					if exist( path, 'dir' ) ~= 7
						mkdir( path );
					end 
					saveas( gcf, [ path, get(gcf,'Name'), '.fig' ] );
					saveas( gcf, [ path, get(gcf,'Name'), '.bmp' ] );
				end

				for i = 1 : 3
					figure; hold on;
					set( gcf, 'NumberTitle', 'off', 'Name', [ 'block', num2str(iFirst), '-', num2str(iLast), '_Break_Distribution_iGroup', num2str(iGroup), '_', num2str(i) ] );
					if showResponseLoc
						for nBlock = iFirst : iLast	
							obj.blocks(nBlock).ResponseLocDist();
						end
					end
					plot( data{i+6}(1,:), data{i+6}(2,:), 'c:' ); axis equal;
					plot( data{i+6}(1,1:3:end-2), data{i+6}(2,1:3:end-2), 'c.' );
					plot( data{i+6}(1,2:3:end-1), data{i+6}(2,2:3:end-1), 'r.' );
					plot( fix(cue/10000) - 250, mod(cue,1000) - 250, 'g.' );
					if ~showResponseLoc
						for nBlock = iFirst : iLast
							loc = obj.blocks(nBlock).ResponseLocDist();
							plot( loc( 1 : 2 : end -1 ), loc( 2 : 2 : end ), 'k*' );
						end
					end
				end

			end

		end

		function RepeatDist( obj, path )
			nColumns = 5;
			nRows = ceil( obj.nBlocks / nColumns );
			if nRows == 1
				nColumns = obj.nBlocks;
			end

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'Error&Break Repeat' );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
			for i = 1 : obj.nBlocks
				subplot( nRows, nColumns, i ); hold on;
				obj.blocks(i).RepeatDist();
			end
			set( gcf, 'CurrentAxes', axes( 'unit', 'normalized', 'position', [0 0 1 1], 'visible', 'off', 'NextPlot', 'add', 'hittest', 'off' ) );
			plot( 0, 0, 'b', 'LineWidth', 10);
			plot( 0, 0, 'r', 'LineWidth', 10);
			legend( 'same', 'diff' );

			if nargin == 2 && ~isempty(path)
				if path(end) ~= '\' && path(end) ~= '/'
					path(end+1) = '/';
				end
				if exist( path, 'dir' ) ~= 7
					mkdir( path );
				end 
				saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.fig'  ] );
				saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.bmp'  ] );
			end
		end

		function MicroSacDist( obj, iFirst, iLast, groupEdges, t_step, ang_step )
			%% iFirst:		index of the first block to analyze
			%  iLast:		for the last block to analyze
			%  gropuEdges:	edges to group cue conditions( range of [-180, 180] )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 || isempty(groupEdges) )
				groupEdges = [-180,180];
			end
			if( nargin() <= 4 )
				t_step = 0.01;
			end
			if( nargin() <= 5 )
				ang_step = 2;
			end

			if( iFirst > iLast )
				return;
			elseif( iFirst < 1 )
				iFirst = 1;
			elseif( iFirst > obj.nBlocks )
				iFirst = obj.nBlocks;
			end
			if( iLast < 1 )
				iLast = 1;
			elseif( iLast > obj.nBlocks )
				iLast = obj.nBlocks;
			end

			nCueGroups = size(groupEdges,2) - 1;
			if( nCueGroups <= 0 )
				disp('Usage: obj.MicroSacDist( [ iFirst=1, iFirst=end, groupEdges=[-180,180] ] )');
				fprintf('\tgroupEdges: a vector containing edges to group cue conditions; its size should be larger than 1.');
				return;
			end

			% termipoints, angle, amplitude, latency, tFp, tCue, tRf, tRf2, cueAng, cueLoc, tarAng, tarLoc
			N = 3 * sum( [ obj.blocks(iFirst:iLast).nCorrect ] );
			microSaccades.termiPoints	= zeros( 2, N*3, 'single' );
			microSaccades.angle			= zeros( 1, N, 'single' );
			microSaccades.latency		= zeros( 1, N, 'single' );
			microSaccades.tFp			= zeros( 1, N, 'single' );
			microSaccades.tCue			= zeros( 1, N, 'single' );
			microSaccades.tRf			= zeros( 1, N, 'single' );
			microSaccades.tRf2			= zeros( 1, N, 'single' );
			microSaccades.cueAng		= zeros( 1, N, 'single' );
			microSaccades.cueLoc		= zeros( 2, N, 'single' );
			microSaccades.tarAng		= zeros( 1, N, 'single' );
			microSaccades.tarLoc		= zeros( 2, N, 'single' );
			microSaccades.count			= 0;

			for( iBlock = iFirst : iLast )
				trials = obj.blocks(iBlock).trials( [ obj.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT &...
													[ 1, [obj.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
				for( i = 1 : size( trials, 2 ) )
					for( j = 1 : trials(i).iResponse1 - 1 )
						if( trials(i).saccades(j).latency < trials(i).rf.tOn - 0.2 * MK_CONSTANTS.TIME_UNIT ||...
							any( abs( trials(i).saccades(j).termiPoints(:) ) > 5 ) )% ||...
							%trials(i).saccades(j).amplitude > 1.5
							continue;
						end
						microSaccades.count = microSaccades.count + 1;
						microSaccades.termiPoints( :, microSaccades.count*3-2 : microSaccades.count*3-1 )	= trials(i).saccades(j).termiPoints;
						microSaccades.angle( microSaccades.count )			= trials(i).saccades(j).angle;
						microSaccades.latency( microSaccades.count )		= trials(i).saccades(j).latency;
						microSaccades.tFp( microSaccades.count )			= trials(i).fp.tOn;
						microSaccades.tCue( microSaccades.count )			= trials(i).cue.tOn;
						microSaccades.tRf( microSaccades.count )			= trials(i).rf.tOn;
						microSaccades.tRf2( microSaccades.count )			= trials(i).rf2.tOn;
						%microSaccades.cueAng( microSaccades.count )		= ;
						microSaccades.cueLoc( :, microSaccades.count )		= [ trials(i).cue.x; trials(i).cue.y ];
						%microSaccades.tarAng( microSaccades.count )		= ;
						microSaccades.tarLoc( :, microSaccades.count )		= [ trials(i).jmp1.x; trials(i).jmp1.y ];						
					end
				end
            end
            microSaccades.termiPoints( :, 3:3:microSaccades.count*3 ) = NaN;
			microSaccades.cueAng = cart2pol( microSaccades.cueLoc(1,:), microSaccades.cueLoc(2,:) ) / pi * 180;
			microSaccades.tarAng = cart2pol( microSaccades.tarLoc(1,:), microSaccades.tarLoc(2,:) ) / pi * 180;

			for( iCueGroup = 1 : nCueGroups )
				figure; hold on;
				tit = [ 'MicroSac_cue[', num2str(groupEdges(iCueGroup)), ',', num2str(groupEdges(iCueGroup+1)), ']_blocks[' ];
				for( i = iFirst : iLast )
					tit = [ tit, obj.blocks(i).blockName, ',' ];
				end
				if( tit(end) == ',' )
					tit(end) = ']';
				else
					tit(end+1) = ']';
				end
				set( gcf, 'NumberTitle', 'off', 'Name', tit );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
				
				%nRows	 = 3;
				%nColumns = sum(nTimeBins) + 3;

				index = find( groupEdges(iCueGroup) <= microSaccades.cueAng(1:microSaccades.count) & microSaccades.cueAng(1:microSaccades.count) < groupEdges(iCueGroup+1) );
				if( isempty(index) )
					continue;
				end

				index2( 3 : 3 : size(index,2) * 3 ) = index * 3;
				index2( 2 : 3 : end-1 ) = index2( 3 : 3 : end ) - 1;
				index2( 1 : 3 : end-2 ) = index2( 2 : 3 : end-1 ) - 1;

				subplot(2,2,1); hold on;
				set( gca, 'xlim', [-10,10], 'ylim', [-10,10] );
				plot( microSaccades.termiPoints( 1, index2(2:3:end-1) ) - microSaccades.termiPoints( 1, index2(1:3:end-2) ),...
					  microSaccades.termiPoints( 2, index2(2:3:end-1) ) - microSaccades.termiPoints( 2, index2(1:3:end-2) ), '*r' );
				plot( 0, 0, '*b' );

				subplot(2,2,2); hold on;
				set( gca, 'xlim', [-10,10], 'ylim', [-10,10] );
				plot( microSaccades.termiPoints(1,index2), microSaccades.termiPoints(2,index2), ':' );
				plot( microSaccades.termiPoints( 1, index2(1:3:end-2) ), microSaccades.termiPoints( 2, index2(1:3:end-2) ), '*b' );
				plot( microSaccades.termiPoints( 1, index2(2:3:end-1) ), microSaccades.termiPoints( 2, index2(2:3:end-1) ), '*r' );

				%% plot cue directions
				ang = unique( microSaccades.cueAng(index) );
				xm = get( gca, 'xlim' ); ym = get( gca, 'ylim' );
				x = []; y = [];
				for( i = size(ang,2) : -1 : 1 )
					x(i*3) = NaN;
					x(i*3-2) = 0;
					x(i*3-1) = abs( ym(2) / sin( ang(i) / 180 * pi ) ) * cos( ang(i) / 180 * pi );
					if( x(i*3-1) > xm(2) ), x(i*3-1) = xm(2);
					elseif( x(i*3-1) < xm(1) ), x(i*3-1) = xm(1); end
					y(i*3) = NaN;
					y(i*3-2) = 0;
					y(i*3-1) = abs( xm(2) / cos( ang(i) / 180 * pi ) ) * sin( ang(i) / 180 * pi );
					if( y(i*3-1) > ym(2) ), y(i*3-1) = ym(2);
					elseif( y(i*3-1) < ym(1) ), y(i*3-1) = ym(1); end
				end
				if( size(ang,2) > 0 )
					plot( x, y, 'g' );
				end
				
				%tNames = { 'tRf', 'tCue', 'tCue' };
				angNames = { 'cueAng', 'tarAng' };
				angNames2 = { 'tarAng', 'cueAng' };
				%tAligns = { 'rf on', 'cue on', 'cue on' };
				angAligns = { 'cue', 'target' };
				for( i = 1 : 2 )
					subplot(2,2,i+2);
					t = microSaccades.latency(index) - microSaccades.tCue(index);
					ang = microSaccades.angle(index) - microSaccades.(angNames{i})(index);
					ang( ang < -180 ) = ang( ang < -180 ) + 360;
					ang( ang > 180 )  = ang( ang > 180 )  - 360;
					edges = { min(t)-t_step/2 : t_step : max(t)+t_step/2, -180 : ang_step : 180 };
					%hist3( [t; ang]', 'edges', edges );
					data = hist3( [t; ang]', 'edges', edges );
					set( pcolor( edges{1}, edges{2}, data' ), 'LineStyle', 'none' );
					hold on;

					% show cue or target angles
					angs = unique( microSaccades.(angNames2{i})(index) - microSaccades.(angNames{i})(index) );
					y = zeros( 1, size(angs,2)*3 ) * NaN;
					y( 1 : 3 : end-2 ) = angs;
					y( 2 : 3 : end-1 ) = angs;
					x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
					plot( x, y, 'g:' );

					% show a center window for the angles
					win = 10;
					fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

					%% time points of several events
					% averaged rf on time
					x = double( mean( microSaccades.tRf(index) - microSaccades.tCue(index) ) );
					x(2) = x(1);
					y = get(gca,'ylim');
					plot( x, y, 'w:' );
					text( x(1), y(2), 'rf', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

					% cue on time
					plot( [0 0], y, 'w:' );
					text( 0, y(2), 'cue', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

					% averaged rf2 on time
					x = double( mean( microSaccades.tRf2(index) - microSaccades.tCue(index) ) );
					x(2) = x(1);
					plot( x, y, 'w:' );
					text( x(1), y(2), 'rf2', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

					% cue off time
					plot( [0.2 0.2], y, 'w:' );
					text( 0.2, y(2), 'cue off', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
					
					set( gca, 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ] );
					%set( gca, 'xlim', [ -0.6060 0.6640 ] );
					xlabel( [ 'time aligned to ', 'cue on (s)' ] );
					ylabel( [ 'angle aligned to ', angAligns{i}, ' (\circ)' ] );					
	            end
	            colormap('hot');
	            pause(0.2); for( i = 3:4 ), subplot(2,2,i); colorbar; end
			end

			% figure; hold on;
			% set( gca, 'xlim', [-10,10], 'ylim', [-10,10] );
			% t = microSaccades.latency(1:microSaccades.count) - microSaccades.tCue(1:microSaccades.count);
			% index = find( -0.035 < t & t < 0.003 );
   %          clear index2;
			% index2( 3 : 3 : size(index,2) * 3 ) = index * 3;
			% index2( 2 : 3 : end-1 ) = index2( 3 : 3 : end ) - 1;
			% index2( 1 : 3 : end-2 ) = index2( 2 : 3 : end-1 ) - 1;
			% %plot( microSaccades.termiPoints(1,index2), microSaccades.termiPoints(2,index2), ':' );
			% plot( microSaccades.termiPoints( 1, index2(2:3:end-1) ) - microSaccades.termiPoints( 1, index2(1:3:end-2) ),...
			% 	  microSaccades.termiPoints( 2, index2(2:3:end-1) ) - microSaccades.termiPoints( 2, index2(1:3:end-2) ), '*r' );
			% plot( 0, 0, '*b' );


		end

		function BreakMicrosac( obj, iFirst, iLast, groupEdges, ampEdges, t_step, ang_step )
			%% iFirst:		index of the first block to analyze
			%  iLast:		for the last block to analyze
			%  gropuEdges:	edges to group cue conditions( range of [-180, 180] )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 || isempty(groupEdges) ) groupEdges = [-180,180]; end
			if( nargin() <= 4 ) ampEdges = [0,1.5]; end
			if( nargin() <= 5 ) t_step = 0.01; end
			if( nargin() <= 6 ) ang_step = 2; end

			if( iFirst > iLast ) return;
			elseif( iFirst < 1 ) iFirst = 1;
			elseif( iFirst > obj.nBlocks ) iFirst = obj.nBlocks; end
			if( iLast < 1 )	iLast = 1;
			elseif( iLast > obj.nBlocks ) iLast = obj.nBlocks; end

			nCueGroups = size(groupEdges,2) - 1;
			if( nCueGroups <= 0 )
				disp('Usage: obj.BreakMicrosac( [ iFirst=1, iFirst=end, groupEdges=[-180,180], ampEdges=[0,1.5], t_step=0.01, ang_step=2 ] )');
				fprintf('\tgroupEdges: a vector containing edges to group cue conditions; its size should be larger than 1.');
				return;
			end

			% data for break-saccades
			breakSaccades.angle						= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.latency					= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.tFp						= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.tRf 						= zeros( 1, obj.nFixbreak, 'single' );
            breakSaccades.tRf2 						= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.tCue						= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.cueAng					= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.tarAng					= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.zeroAng					= zeros( 1, obj.nFixbreak, 'single' );
			breakSaccades.count 					= 0;

			% data for micro-saccades
			N = 3 * sum( [ obj.blocks(iFirst:iLast).nCorrect ] );
			microSaccades.angle			= zeros( 1, N, 'single' );
			microSaccades.latency		= zeros( 1, N, 'single' );
			microSaccades.tFp			= zeros( 1, N, 'single' );
			microSaccades.tCue			= zeros( 1, N, 'single' );
			microSaccades.tRf			= zeros( 1, N, 'single' );
			microSaccades.tRf2			= zeros( 1, N, 'single' );
			microSaccades.cueAng		= zeros( 1, N, 'single' );
			cueLoc						= zeros( 2, N, 'single' );
			microSaccades.tarAng		= zeros( 1, N, 'single' );
			tarLoc						= zeros( 2, N, 'single' );
			microSaccades.zeroAng		= zeros( 1, N, 'single' );
			microSaccades.count			= 0;

			for( iBlock = iFirst : iLast )
				%% collect data for break saccades
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
                if( ~isempty(trials) )
                    fp = [trials.fp];
                    rf = [trials.rf];
                    trials( [fp.tOn] < 0 | [rf.tOn] < 0 ) = [];
                end
                if( ~isempty(trials) )
                    fp( [fp.tOn] < 0 | [rf.tOn] < 0 ) = [];
                    if( ~isempty(trials) )
                        cnt = breakSaccades.count + size(trials,2);

                        [ ~, sacs ] = trials.GetBreak();
                        breakSaccades.angle( breakSaccades.count+1 : cnt ) = [sacs.angle];
                        breakSaccades.latency( breakSaccades.count+1 : cnt ) = [sacs.latency];

                        breakSaccades.tFp( breakSaccades.count+1 : cnt ) = [fp.tOn];

                        rf = [trials.rf];
                        breakSaccades.tRf( breakSaccades.count+1 : cnt ) = [ rf.tOn ];
                        % breakSaccades.tRf( breakSaccades.tRf < 0 ) = obj.blocks(iBlock).GetTFromFp( REX_CODE_MAP.RFON ) + [ fp( [rf.tOn] < 0 ).tOn ];

                        rf2 = [trials.rf2];
                        breakSaccades.tRf2( breakSaccades.count+1 : cnt ) = [ rf2.tOn ];
                        breakSaccades.tRf2( breakSaccades.tRf2 < 0 ) = obj.blocks(iBlock).GetTFromFp( REX_CODE_MAP.RF2ON ) + [ fp( [rf2.tOn] < 0 ).tOn ];

                        cue = [ trials.cue ];
                        breakSaccades.tCue( breakSaccades.count+1 : cnt ) = [ cue.tOn ];
                        breakSaccades.tCue( breakSaccades.tCue < 0 ) = obj.blocks(iBlock).GetTFromFp( REX_CODE_MAP.CUEON ) + [ fp( [cue.tOn] < 0 ).tOn ];

                        breakSaccades.cueAng( breakSaccades.count+1 : cnt ) = cart2pol( [cue.x], [cue.y] ) / pi * 180;

                        breakSaccades.count = cnt;
                    end
                end


				%% collect data for micro-saccades
				trials = obj.blocks(iBlock).trials( [ obj.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT &...
													[ 1, [obj.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
				for( i = 1 : size( trials, 2 ) )
					for( j = 1 : trials(i).iResponse1 - 1 )
						if( trials(i).saccades(j).latency < trials(i).rf.tOn - 0.2 * MK_CONSTANTS.TIME_UNIT ||...
							any( abs( trials(i).saccades(j).termiPoints(:) ) > 5 ) ||...
							trials(i).saccades(j).amplitude < ampEdges(1) ||...
							trials(i).saccades(j).amplitude >= ampEdges(2) )
							continue;
						end
						microSaccades.count = microSaccades.count + 1;
						microSaccades.angle( microSaccades.count )			= trials(i).saccades(j).angle;
						microSaccades.latency( microSaccades.count )		= trials(i).saccades(j).latency;
						microSaccades.tFp( microSaccades.count )			= trials(i).fp.tOn;
						microSaccades.tCue( microSaccades.count )			= trials(i).cue.tOn;
						microSaccades.tRf( microSaccades.count )			= trials(i).rf.tOn;
						microSaccades.tRf2( microSaccades.count )			= trials(i).rf2.tOn;
						cueLoc( :, microSaccades.count )					= [ trials(i).cue.x; trials(i).cue.y ];
						tarLoc( :, microSaccades.count )					= [ trials(i).jmp1.x; trials(i).jmp1.y ];						
					end
				end
            end
			microSaccades.cueAng = cart2pol( cueLoc(1,:), cueLoc(2,:) ) / pi * 180;
			microSaccades.tarAng = cart2pol( tarLoc(1,:), tarLoc(2,:) ) / pi * 180;

			%% plot figure
			for( iGroup = 1 : nCueGroups )
				figure;
				tit = [ 'BreakMicroSac_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)),']_cue[', num2str(groupEdges(iGroup)), ',', num2str(groupEdges(iGroup+1)), ']_blocks[' ];
				for( i = iFirst : iLast )
					tit = [ tit, obj.blocks(i).blockName, ',' ];
				end
				if( tit(end) == ',' )
					tit(end) = ']';
				else
					tit(end+1) = ']';
				end
				set( gcf, 'NumberTitle', 'off', 'Name', tit );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);

				data = [ breakSaccades, microSaccades ];
				for( iData = 1 : 2 )
					index = find( groupEdges(iGroup) < data(iData).cueAng(1:data(iData).count) & data(iData).cueAng(1:data(iData).count) < groupEdges(iGroup+1) |...
								  groupEdges(iGroup) - 360 < data(iData).cueAng(1:data(iData).count) & data(iData).cueAng(1:data(iData).count) < groupEdges(iGroup+1) - 360 );
                    if( isempty(index) ) continue; end
					angNames = { 'cueAng', 'zeroAng' };
					angNames2 = { 'zeroAng', 'cueAng' };
					%tAligns = { 'rf on', 'cue on', 'cue on' };
					angAligns = { 'cue', 'zero' };
					for( i = 1 : 2 )
						subplot( 2, 2, iData*2 - 2 + i );
						t = data(iData).latency(index) - data(iData).tCue(index);
						ang = data(iData).angle(index) - data(iData).(angNames{i})(index);
						% ang( t > 0.4 ) = [];
						% t( t > 0.4 ) = [];
						ang( ang < -180 ) = ang( ang < -180 ) + 360;
						ang( ang > 180 )  = ang( ang > 180 )  - 360;
						%edges = { min(t)-t_step/2 : t_step : max(t)+t_step/2, -180 : ang_step : 180 };
						edges = { -0.9 : t_step : 0.7, -180 : ang_step : 180 };
						%hist3( [t; ang]', 'edges', edges );
						cdata = hist3( [t; ang]', 'edges', edges );
                        if( ~isempty(cdata) )
                            set( pcolor( edges{1}, edges{2}, cdata' ), 'LineStyle', 'none' );
                        end
						hold on;

						% show cue or zero angles
						angs = unique( data(iData).(angNames2{i})(index) - data(iData).(angNames{i})(index) );
						y = zeros( 1, size(angs,2)*3 ) * NaN;
						y( 1 : 3 : end-2 ) = angs;
						y( 2 : 3 : end-1 ) = angs;
						x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
						plot( x, y, ':', 'color', [0 0.4 0] );

						% show a center window for the angles
						win = 10;
						fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

						%% time points of several events
						% averaged rf on time
						x = double( mean( data(iData).tRf(index) - data(iData).tCue(index) ) );
						x(2) = x(1);
						y = get(gca,'ylim');
						plot( x, y, 'w:' );
						text( x(1), y(2), 'rf', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

						% show -90, 0, 90 degrees
			            plot( [ edges{1}(1), edges{1}(end) ], [-90 -90], 'w:' );
			            plot( [ edges{1}(1), edges{1}(end) ], [0 0], 'w:' );
			            plot( [ edges{1}(1), edges{1}(end) ], [90 90], 'w:' );

						% cue on time
						plot( [0 0], y, 'w:' );
						text( 0, y(2), 'cue', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

						% % averaged rf2 on time
						% x = double( mean( data(iData).tRf2(index) - data(iData).tCue(index) ) );
						% x(2) = x(1);
						% plot( x, y, 'w:' );
						% text( x(1), y(2), 'rf2', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

						% cue off time
						plot( [0.2 0.2], y, 'w:' );
						text( 0.2, y(2), 'cue off', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
						
						set( gca, 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ] );
						xlabel( [ 'time aligned to ', 'cue on (s)' ] );
						ylabel( [ 'angle aligned to ', angAligns{i}, ' (\circ)' ] );

						%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
						%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
						if( iData == 2 && i == 2 )
							index = ang > 0 & t > 0.075;
							nUp = sum(index);
							tmpAng = ang(index);
							tmpT = t(index);
							p = polyfit( tmpT, tmpAng, 1);
							[r pval] = corrcoef( tmpT, tmpAng );
							plot( [0.075, edges{1}(end)], polyval( p, [0.075, edges{1}(end)] ), 'b', 'LineWidth', 2 );
							text( 0.2, -180-20, [ 'k1 = ', sprintf('%8.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
							if( size(r,1) == 2 )
								text( 0.2, -180-40, [ 'r1 = ', sprintf('%8.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
								text( 0.2, -180-60, [ 'p1 = ', sprintf('%8.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
							end
							%% Show the averaged curve
							cdata = hist3( [tmpT; tmpAng]', 'edges', { 0.075:t_step:0.5, 0:180 } )';
							plot( 0.075:t_step:0.5, ( [0:180] * cdata ) ./ ( ones(1,181) * cdata ), 'c', 'LineWidth', 1 );


							index = ang < 0 & t > 0.075;
							nDown = sum(index);
							tmpAng = ang(index);
							tmpT	= t(index);
							p = polyfit( tmpT, tmpAng, 1 );
							[r pval] = corrcoef( tmpT, tmpAng );
							plot( [0.075, edges{1}(end)], polyval( p, [0.075, edges{1}(end)] ), 'b', 'LineWidth', 2 );
							text( 0.55, -180-20, [ 'k2 = ', sprintf('%8.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
							if( size(r,1) == 2 )
								text( 0.55, -180-40, [ 'r2 = ', sprintf('%8.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
								text( 0.55, -180-60, [ 'p2 = ', sprintf('%8.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
							end
							%% Show the averaged curve
							cdata = hist3( [tmpT; tmpAng]', 'edges', { 0.075:t_step:0.5, -180:0 } )';
							plot( 0.075:t_step:0.5, ( [-180:0] * cdata ) ./ ( ones(1,181) * cdata ), 'c', 'LineWidth', 1 );

							text( 0.35, 180+40, [ 'ratio1 = ', sprintf('%7.4f',nUp/(nUp+nDown)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
							text( 0.35, 180+20, [ 'ratio2 = ', sprintf('%7.4f',nDown/(nUp+nDown)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

						end
					end
	            end
	            colormap('hot');
	            pause(0.5); for( i = 1:4 ), subplot(2,2,i); colorbar; end
			end
		end

		%% MicrosacFitting: fit the direction change of micro-saccades after cue on
		function stats = MicrosacFitting( obj, iFirst, iLast, groupEdges, ampEdges )
			%% iFirst:		index of the first block to analyze
			%  iLast:		for the last block to analyze
			%  ampEdges:	range of microsaccade amplitute
			%  gropuEdges:	edges to group cue conditions( range of [-180, 180] )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 || isempty(ampEdges) ) ampEdges = [0,1.5]; end
			if( nargin() <= 4 || isempty(groupEdges) ) groupEdges = [-180,180]; end

			if( iFirst > iLast ) return;
			elseif( iFirst < 1 ) iFirst = 1;
			elseif( iFirst > obj.nBlocks ) iFirst = obj.nBlocks; end
			if( iLast < 1 )	iLast = 1;
			elseif( iLast > obj.nBlocks ) iLast = obj.nBlocks; end

			nCueGroups = size(groupEdges,2) - 1;
			if( nCueGroups <= 0 )
				disp('Usage: obj.MicrosacFitting( [ iFirst=1, iFirst=end, groupEdges=[-180,180] ] )');
				fprintf('\tgroupEdges: a vector containing edges to group cue conditions; its size should be larger than 1.');
				return;
			end

			N = 3 * sum( [ obj.blocks(iFirst:iLast).nCorrect ] );
			microSaccades.angle			= zeros( 1, N, 'single' );
			microSaccades.latency		= zeros( 1, N, 'single' );
			microSaccades.tFp			= zeros( 1, N, 'single' );
			microSaccades.tCue			= zeros( 1, N, 'single' );
			microSaccades.tRf			= zeros( 1, N, 'single' );
			microSaccades.tRf2			= zeros( 1, N, 'single' );
			microSaccades.cueAng		= zeros( 1, N, 'single' );
			cueLoc						= zeros( 2, N, 'single' );
			microSaccades.tarAng		= zeros( 1, N, 'single' );
			tarLoc						= zeros( 2, N, 'single' );
			microSaccades.zeroAng		= zeros( 2, N, 'single' );
			microSaccades.count			= 0;

			for( iBlock = iFirst : iLast )
				trials = obj.blocks(iBlock).trials( [ obj.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT &...
														[ 1, [obj.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
				for( i = 1 : size( trials, 2 ) )
					for( j = 1 : trials(i).iResponse1 - 1 )
						if( trials(i).saccades(j).latency < trials(i).rf.tOn - 0.2 * MK_CONSTANTS.TIME_UNIT ||...
							any( abs( trials(i).saccades(j).termiPoints(:) ) > 5 ) ||...
							trials(i).saccades(j).amplitude < ampEdges(1) ||...
							trials(i).saccades(j).amplitude >= ampEdges(2) )
							continue;
						end
						microSaccades.count = microSaccades.count + 1;
						microSaccades.angle( microSaccades.count )			= trials(i).saccades(j).angle;
						microSaccades.latency( microSaccades.count )		= trials(i).saccades(j).latency;
						microSaccades.tFp( microSaccades.count )			= trials(i).fp.tOn;
						microSaccades.tCue( microSaccades.count )			= trials(i).cue.tOn;
						microSaccades.tRf( microSaccades.count )			= trials(i).rf.tOn;
						microSaccades.tRf2( microSaccades.count )			= trials(i).rf2.tOn;
						cueLoc( :, microSaccades.count )					= [ trials(i).cue.x; trials(i).cue.y ];
						tarLoc( :, microSaccades.count )					= [ trials(i).jmp1.x; trials(i).jmp1.y ];						
					end
				end
			end
			microSaccades.cueAng = cart2pol( cueLoc(1,:), cueLoc(2,:) ) / pi * 180;
			microSaccades.tarAng = cart2pol( tarLoc(1,:), tarLoc(2,:) ) / pi * 180;

			stats.k = [];
			stats.b = [];
			stats.r = [];
			stats.p = [];
			for( iGroup = nCueGroups : -1 : 1 )
				index = find( groupEdges(iGroup) < microSaccades.cueAng(1:microSaccades.count) & microSaccades.cueAng(1:microSaccades.count) < groupEdges(iGroup+1) |...
							  groupEdges(iGroup) < microSaccades.cueAng(1:microSaccades.count) + 360 & microSaccades.cueAng(1:microSaccades.count) + 360 < groupEdges(iGroup+1) );
	            if( isempty(index) ) continue; end
				t = microSaccades.latency(index) - microSaccades.tCue(index);
				ang = microSaccades.angle(index);
				ang( ang < -180 ) = ang( ang < -180 ) + 360;
				ang( ang > 180 )  = ang( ang > 180 )  - 360;

				index = ang > 0 & t > 0.075;
				nUp = sum(index);
				tmpAng = ang(index);
				tmpT = t(index);
				stats.k(iGroup).up = polyfit( tmpT, tmpAng, 1);
				stats.b(iGroup).up = stats.k(iGroup).up(2);
				stats.k(iGroup).up(2) = [];
				[r,p] = corrcoef( tmpT, tmpAng );
				if( size(r,1) ~= 2 )
					r(2) = r(1);
					p(2) = p(1);
				end
				stats.r(iGroup).up = r(2);
				stats.p(iGroup).up = p(2);

				index = ang < 0 & t > 0.075;
				nDown = sum(index);
				tmpAng = ang(index);
				tmpT	= t(index);
				stats.k(iGroup).down = polyfit( tmpT, tmpAng, 1 );
				stats.b(iGroup).down = stats.k(iGroup).down(2);
				stats.k(iGroup).down(2) = [];
				[r,p] = corrcoef( tmpT, tmpAng );
				if( size(r,1) ~= 2 )
					r(2) = r(1);
					p(2) = p(1);
				end
				stats.r(iGroup).down = r(2);
				stats.p(iGroup).down = p(2);

				stats.ratio(iGroup).up = nUp / ( nUp + nDown );
				stats.ratio(iGroup).down = nDown / ( nUp + nDown );
				stats.num(iGroup).up = nUp;
				stats.num(iGroup).down = nDown;
			end

		end


		function latency = ReactionTime( obj )
			latency(2).rt = zeros( 1, obj.nTrials );	% first one for left, second for right
			latency(2).cnt = 0;
			latency(1).rt = zeros( 1, obj.nTrials );
			latency(1).cnt = 0;
			for( iBlock = 1 : obj.nBlocks )
				first = true;
				for( trial = obj.blocks(iBlock).trials )
					if( trial.type == TRIAL_TYPE_DEF.CORRECT &&...
						( first || trial.type == TRIAL_TYPE_DEF.CORRECT ) &&...
						size( find( [ trial.saccades( 1 : trial.iResponse1 ).latency ] > trial.cue.tOn ), 2 ) > 1 )
						
						first = false;
						index = 0;
						if( trial.cue.x < 0 ), index = 1;
						elseif( trial.cue.x > 0 ), index = 2; end
						if( index )
							latency(index).cnt = latency(index).cnt+1;
							latency(index).rt( latency(index).cnt ) = trial.saccades( trial.iResponse1 ).latency - trial.jmp1.tOn;
						end
					end
				end
			end
			if( nargout() == 1 ), return; end

			figure; hold on;
			set( gcf, 'NumberTitle', 'off', 'Name', 'ReactionTime' );
		 	colors = 'gr';
		 	t_step = 0.01;
		 	for( i = 2 : -1 : 1 )
		 		data = latency(i).rt( 1 : latency(i).cnt );
		 		[data, ax] = hist( data, min(data) - t_step/2 : t_step : max(data) + t_step );
				h(i) = bar( ax, data/sum(data), 1 );
				set( h(i), 'LineStyle', 'none', 'FaceColor', colors(i) );
				set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
		 	end
		 	legend( h, 'left', 'right' );
		 	set( gca, 'xlim', [-0.2,0.35], 'ylim', [0 0.4] );
		end


		function angles = BreakBeforeCue( obj, iFirst, iLast )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end

			angles = zeros( 1, obj.nFixbreak );
			count = 0;
			for( iBlock = iFirst : iLast )
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
				
				%%%%%% for color cue task
				index = false(size(trials));
				for( i = 1 : size(trials,2) )
					if( size( trials(i).rf, 2 ) > 1 || any( trials(i).rf.y ~= 0 )  ) index(i) = true; end
				end
				trials(index) = [];

                if( isempty(trials) ), continue; end;
				cue = [trials.cue];
				rf = [trials.rf];
                rf2 = [trials.rf2];
                jmp1 = [trials.jmp1];
				% trials = trials( [rf.tOn] > 0 & [cue.tOn] < 0 );
				trials = trials( [rf.tOn] < 0 );	%%%%%% for color cue
                if( isempty(trials) ), continue; end;
                [ ~, breakSacs ] = trials.GetBreak();
                tAngs = [breakSacs.angle];
                angles( count+1 : count + size(tAngs,2) ) = tAngs;
                count = count + size(tAngs,2);
			end
			angles = angles(1:count);
			if( nargout() == 1 ), return; end

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'BreakBeforeCue' );
			subplot(2,2,[1 3]);
			polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
			
			subplot(2,2,2);
			ang_step = 10;
			[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax, data/sum(data), 1 );
			set( h, 'LineStyle', 'none', 'FaceColor', 'g' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );

			ang_win = 90;
			left = size( angles( angles < -180 + ang_win | angles > 180 - ang_win ), 2 ) / count;
			right = size( angles( -ang_win < angles & angles < ang_win ), 2 ) / count;
			subplot(2,2,4); hold on;
			bar( 1, left, 0.5, 'g' );
			text( 1, 0, 'left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			bar( 2, right, 0.5, 'r' );
			text( 2, 0, 'right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ] );
		end

		function angles = BreakAfterCue( obj, iFirst, iLast )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end

			angles.left 	= zeros(1,obj.nFixbreak);
			angles.right 	= zeros(1,obj.nFixbreak);
			count.left		= 0;
			count.right		= 0;
			for( iBlock = iFirst : iLast )
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
				
				%%%%%% for color cue task
				index = false(size(trials));
				for( i = 1 : size(trials,2) )
					if( size( trials(i).rf, 2 ) > 1 || any( trials(i).rf.y ~= 0 ) ) index(i) = true; end
				end
				trials(index) = [];

				if( isempty(trials) ) continue; end;
				cue = [trials.cue];
				% trials = trials( [cue.tOn] > 0 );
				rf = [trials.rf];	%%%%%% for color cue
				trials = trials( [rf.tOn] > 0 );	%%%%%% for color cue
				if( isempty(trials) ) continue; end;
				[ ~, breakSacs ] = trials.GetBreak();
				cue = [trials.cue];
				left = breakSacs( [cue.x] < 0 );
				left = [left.angle];
				right = breakSacs( [cue.x] > 0 );
				right = [right.angle];

				%%%%%% for color cue
				rf = [trials.rf];
				red = [rf.red];
				red = red(1:2:end);
				left = breakSacs( red > 0 );
				left = [left.angle];
				right = breakSacs( red == 0 );
				right = [right.angle];

				angles.left( count.left+1 : count.left + size(left,2) ) = left;
				count.left = count.left + size(left,2);
				angles.right( count.right+1 : count.right + size(right,2) ) = right;
				count.right = count.right + size(right,2);
			end
			angles.left = angles.left(1:count.left);
			angles.right = angles.right(1:count.right);
			if( nargout() == 1 ) return; end

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'BreakAfterCue' );
			subplot(2,2,[1 3]);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			
			subplot(2,2,2);
			hold on;
			ang_step = 10;
			[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax, data/sum(data), 0.5, 'g' );
			[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax+ang_step/2, data/sum(data), 0.5, 'r' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );

			ang_win = 15;
			left = sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / count.right;
			right = sum( -ang_win < angles.left & angles.left < ang_win ) / count.left;
			subplot(2,2,4); hold on;
			bar( 1, left, 0.5, 'g' );
			text( 1, 0, 'left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			bar( 2, right, 0.5, 'r' );
			text( 2, 0, 'right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ] );
		end

		function data = ConditionedErrorDirection( obj, iFirst, iLast)
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end

			data.left.breakAngles 	= zeros(1,obj.nFixbreak);	% target/cue left
			data.left.errorAngles	= zeros(1,obj.nError);
			data.left.nCorrect		= 0;
			data.left.nError		= 0;
			data.left.nFixbreak		= 0;
			data.right.breakAngles 	= zeros(1,obj.nFixbreak);	% target/cue right
			data.right.errorAngles	= zeros(1,obj.nError);
			data.right.nCorrect		= 0;
			data.right.nError		= 0;
			data.right.nFixbreak	= 0;
			count.leftBreaks		= 0;
			count.leftErrors		= 0;
			count.rightBreaks		= 0;
			count.rightErrors		= 0;
			for( iBlock = iFirst : iLast )
				%% collect error angles for each condition (left and right)
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.ERROR );
				if( ~isempty(trials) )
					jmp1 = [trials.jmp1];
					data.left.nError	= data.left.nError + sum( [jmp1.x] < 0 );
					data.right.nError	= data.right.nError + sum( [jmp1.x] > 0 );
					index = [];
					j1win = 5;
					for( i = size(trials,2) : -1 : 1 )
						errorSacs(i) = trials(i).saccades(trials(i).iResponse1);
						if( trials(i).jmp1.x - j1win < errorSacs(i).termiPoints(1,2) && errorSacs(i).termiPoints(1,2) < trials(i).jmp1.x + j1win &&...
							trials(i).jmp1.y - j1win < errorSacs(i).termiPoints(2,2) && errorSacs(i).termiPoints(2,2) < trials(i).jmp1.y + j1win )
							index = [index,i];
						end
					end
					trials(index) = [];	% remove correct "error trials"
					if( ~isempty(trials) )
						jmp1 = [trials.jmp1];
						leftErrors	= errorSacs( [jmp1.x] < 0 );
						rightErrors	= errorSacs( [jmp1.x] > 0 );
						data.left.errorAngles( count.leftErrors+1 : count.leftErrors + size(leftErrors,2) ) = [leftErrors.angle];
						count.leftErrors = count.leftErrors + size(leftErrors,2);
						data.right.errorAngles( count.rightErrors+1 : count.rightErrors + size(rightErrors,2) ) = [rightErrors.angle];
						count.rightErrors = count.rightErrors + size(rightErrors,2);
					end
				end

				%% collect number of correct trials for each condition (left and right)
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT );
				if( ~isempty(trials) )
					jmp1 = [trials.jmp1];
					data.left.nCorrect 	= data.left.nCorrect + sum( [jmp1.x] < 0 );
					data.right.nCorrect = data.right.nCorrect + sum( [jmp1.x] > 0 );
				end

				%% collect break angels (after cue on) and number of breaks for each condition (left and right)
				trials = obj.blocks(iBlock).trials( [obj.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
				if( ~isempty(trials) )
					cue = [trials.cue];
					trials( [cue.tOn] < 0 ) = [];
					if( ~isempty(trials) )
						cue = [trials.cue];
						[ ~, breakSacs ] = trials.GetBreak();

						leftBreaks = breakSacs( [cue.x] < 0 );
						data.left.breakAngles( count.leftBreaks+1 : count.leftBreaks + size(leftBreaks,2) ) = [leftBreaks.angle];
						count.leftBreaks = count.leftBreaks + size(leftBreaks,2);
						data.left.nFixbreak	= data.left.nFixbreak + size(leftBreaks,2);

						rightBreaks = breakSacs( [cue.x] > 0 );
						data.right.breakAngles( count.rightBreaks+1 : count.rightBreaks + size(rightBreaks,2) ) = [rightBreaks.angle];
						count.rightBreaks = count.rightBreaks + size(rightBreaks,2);
						data.right.nFixbreak = data.right.nFixbreak + size(rightBreaks,2);
					end
				end

			end
			data.left.errorAngles = data.left.errorAngles(1:count.leftErrors);
			data.left.breakAngles = data.left.breakAngles(1:count.leftBreaks);
			data.right.errorAngles = data.right.errorAngles(1:count.rightErrors);
			data.right.breakAngles = data.right.breakAngles(1:count.rightBreaks);
			if( nargout() == 1 ) return; end


			leftAngles = [ data.left.errorAngles, data.left.breakAngles ];
			rightAngles = [ data.right.errorAngles, data.right.breakAngles ];
			nLeftTrials = data.right.nCorrect + data.right.nError + data.right.nFixbreak;
			nRightTrials = data.left.nCorrect + data.right.nError + data.left.nFixbreak;
			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'ConditionedErrorDirection' );
			subplot(2,2,[1 3]);
			polar( (-180:180)/180*pi, hist( leftAngles, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( rightAngles, -180:180 ), 'r' );
			
			subplot(2,2,2);
			hold on;
			ang_step = 10;
			[cdata, ax] = hist( leftAngles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax, cdata/sum(cdata), 0.5, 'g' );
			[cdata, ax] = hist( leftAngles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax+ang_step/2, cdata/sum(cdata), 0.5, 'r' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );

			ang_win = 15;
			left = sum( rightAngles < -180 + ang_win | rightAngles > 180 - ang_win ) / nLeftTrials;
			right = sum( -ang_win < leftAngles & leftAngles < ang_win ) / nRightTrials;
			subplot(2,2,4); hold on;
			bar( 1, left, 0.5, 'g' );
			text( 1, 0, 'left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			bar( 2, right, 0.5, 'r' );
			text( 2, 0, 'right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center' );
			set( gca, 'xtick', [], 'xlim', [0 3] );%, 'ylim', [0 1] );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ] );
		end
		

		function ShowImage( obj, index, path )
			switch index
				case 1
					nSaccades = obj.nSaccades.rf;
					aligned = 'rf_';
				case 2
					nSaccades = obj.nSaccades.cue;
					aligned = 'cue_';
				case 3
					nSaccades = obj.nSaccades.rf2;
					aligned = 'rf2_';
				otherwise
					return;						
			end

			for i = 1 : size( nSaccades, 3 )
				img = zeros(  size( nSaccades, 1 ), size( nSaccades, 2 ), 3 );				
				img(:,:,1) = ceil( nSaccades(:,:,i) ) * 255;
				cueAng = obj.cueConditions(i);
				if cueAng < 0
					cueAng = cueAng + 360;
				end
				cueAng = round( cueAng );
				if cueAng == 0
					cueAng = 360;
				end
				img( cueAng, :, 2 ) = 255;

				img = uint8(img);
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', [ 'sacs_dist_aligned2', aligned, num2str(obj.cueConditions(i))] );
				pause(0.1);
				image( img );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
			 	if nargin == 3 && ~isempty(path)
					if path(end) ~= '\' && path(end) ~= '/'
						path(end+1) = '/';
					end
					if exist( path, 'dir' ) ~= 7
						mkdir( path );
					end 
					saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.fig'  ] );
					saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.bmp'  ] );
				end
			end
		end

		function PlotPopVec( obj, index, path, isGroup )
			switch index
				case 1
					nSaccades = obj.nSaccades.rf;
					align_t = 200;
					aligned = 'rf_';
				case 2
					nSaccades = obj.nSaccades.cue;
					align_t = round( ( obj.tCue - obj.tRf ) * 1000 ) + 200;
					aligned = 'cue_';
				case 3
					nSaccades = obj.nSaccades.rf2;
					align_t = 200;	%round( ( obj.tRf2 - obj.tRf ) * 1000 ) + 200;
					aligned = 'rf2_';
				otherwise
					return;
			end
			cueConditions = obj.cueConditions;

			if nargin == 4 && isGroup	% group the data according to 4 quadrants
				for i = 4 : -1 : 1
					index(i) = find( cueConditions <= i*90-180 & cueConditions > i*90-270, 1, 'first' );
					n = find( cueConditions <= i*90-180 & cueConditions > i*90-270 );
					nSaccades(:,:,index(i)) = sum( nSaccades( :, :, n ), 3 ) ./ size(n,2);
				end
				nSaccades = nSaccades(:,:,index(:));
				cueConditions = [ 135, 45, -45, -135 ];
			end

			rate = convn( sum( nSaccades, 1 ), ones(1,10)*100, 'same' );
			rate = convn( rate, ones(1,10)/10, 'same' );

			polarRadius = 0;
			fh = zeros( 1, size(nSaccades,3) );
			ah = zeros( 1, size(nSaccades,3) );
			for icue = 1 : size( nSaccades, 3 )
			 	x = cos((1:360)/180*pi) * nSaccades(:,:,icue);
			 	y = sin((1:360)/180*pi) * nSaccades(:,:,icue);
			 	x = conv( x, ones(10,1)/10, 'same' );
			 	y = conv( y, ones(10,1)/10, 'same' );
			 	[ popVec.angle, popVec.radius ] = cart2pol( x, y );
			 	popVec.angle( end + 1 - find( popVec.angle(end:-1:1) ~= 0, 1, 'first' ) : end ) = [];
			 	popVec.angle( popVec.angle == 0 ) = NaN;
			 	popVec.angle( find( ~isnan(popVec.angle), 1, 'last' ) + 1 : end ) = [];
			 	for i = 1 : 5
			 		popVec.angle = conv( popVec.angle, ones(10,1)/10, 'same' );
			 	end
			 	popVec.angle = popVec.angle / pi * 180;

				fh(icue) = figure;
				set( gcf, 'NumberTitle', 'off', 'Name', [ 'dynamic_PopVec_aligned2', aligned, num2str(cueConditions(icue)) ] );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
				% ah(icue) = subplot(1,2,1);
				% polar( popVec.angle, 1:size(popVec.angle,2) ); hold on;
				% polar( (1:360)/180*pi, ones(1,360)*align_t, 'r' );
				% polar( ( [ 0 -0.2 0.2 0 ] + cueConditions(icue) ) / 180 * pi, [ 0, size(popVec.angle,2), size(popVec.angle,2), 0 ], 'g' );
				% polarRadius = max( polarRadius, size(popVec.angle,2) + 1 );
				% subplot(1,2,2); hold on;
				nDots = size( popVec.angle, 2 );
				hTCue = plot( [ align_t, align_t], [-180,180], 'r', 'DisplayName', 'Cue On' ); hold on;
				hCue = plot( [ 0 nDots ], ones(1,2) * cueConditions(icue), 'g', 'LineWidth', 2, 'DisplayName', 'Cue Direct' );
				plot( [ 0 nDots ], ones(1,2) * 90, 'k:' );
				plot( [ 0 nDots ], -ones(1,2) * 90, 'k:' );
				[ ax hOri hRate ] = plotyy( 1 : nDots , popVec.angle, 1 : nDots, rate( 1, 1:nDots, icue ) );
				set( ax(1), 'ylim', [-180,180], 'yTick', -180:45:180 );
				y = get( ax(2), 'ylim' );
				set( ax(2), 'yTick', y(1) : 0.5 : y(2) );
				set( hOri, 'DisplayName', 'PopVec' );
				set( hRate, 'DisplayName', 'Rate' );
				fill( [ 1:nDots, nDots:-1:1 ], [ popVec.angle + rate( 1, 1:nDots, icue ) * 10, popVec.angle(end:-1:1) - rate( 1, nDots:-1:1, icue) * 10 ], [0 0 0.5], 'EdgeColor', [0.5,0.5,1], 'FaceColor', [0,0,0.8], 'FaceAlpha', 0.4 );
				legend( [ hTCue, hCue, hOri, hRate ] );
				title( [ 'aligned2: ', aligned(1:end-1) ] );

				if nargin >= 3 && ~isempty(path)
					if path(end) ~= '\' && path(end) ~= '/'
						path(end+1) = '/';
					end
					if exist( path, 'dir' ) ~= 7
						mkdir( path );
					end 
					saveas( fh(icue), [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.fig'  ] );
					saveas( fh(icue), [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.bmp' ] );
				end
				pause(0.1); close all;
			end
			if nargin >= 3 && ~isempty(path)
				close all;
			end
			for icue = 1 : size( nSaccades, 3 )
				% set( fh(icue), 'CurrentAxes', ah(icue) );
				% set( ah(icue), 'xlim', [-polarRadius,polarRadius] );
				% set( ah(icue), 'ylim', [-polarRadius,polarRadius] );
				
			end
		end

		function ShowLFP( obj, iFirst, iLast, groupEdges )
			%% iFirst:		index of the first block to analyze
			%  iLast:		for the last block to analyze
			%  gropuEdges:	edges to group cue conditions( range of [-180, 180] )
			if( nargin() == 1 )
				iFirst = 1;
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 || isempty(groupEdges) ) groupEdges = [-180,180]; end

			if( iFirst > iLast ) return;
			elseif( iFirst < 1 ) iFirst = 1;
			elseif( iFirst > obj.nBlocks ) iFirst = obj.nBlocks; end
			if( iLast < 1 )	iLast = 1;
			elseif( iLast > obj.nBlocks ) iLast = obj.nBlocks; end

			nCueGroups = size(groupEdges,2) - 1;
			if( nCueGroups <= 0 )
				disp('Usage: obj.ShowLFPf( [ iFirst=1, iFirst=end, groupEdges=[-180,180] ] )');
				fprintf('\tgroupEdges: a vector containing edges to group cue conditions; its size should be larger than 1.');
				return;
			end

			trials = [obj.blocks(iFirst:iLast).trials];
			trials = trials( [trials.type] == TRIAL_TYPE_DEF.CORRECT & [ true, [trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
			cue = [trials.cue];
			cue_angs = cart2pol( [cue.x], [cue.y] ) / pi * 180;

			for( i = 1 : nCueGroups )
				index = groupEdges(i) < cue_angs & cue_angs < groupEdges(i+1) | groupEdges(i) - 360 < cue_angs & cue_angs < groupEdges(i+1) - 360;
				groupTrials = trials(index);

				groupCue = [groupTrials.cue];
				tmpAngs = cart2pol( [groupCue.x], [groupCue.y] ) / pi * 180;
				groupCuePos = unique( [ groupCue.x; groupCue.y ]', 'rows' )';

				set( figure, 'NumberTitle', 'off', 'name', sprintf( 'LFP_cue[%.2f,%.2f]', groupEdges(i), groupEdges(i+1) ) );
				ax = [ axes( 'NextPlot', 'add', 'ylim', [1.2 2.6] ) axes( 'NextPlot', 'add', 'color', 'none', 'xlim', [ min([cue.x]) - 2, max([cue.x]) + 2 ], 'xcolor', [1 0 0], 'XAxisLocation', 'top', 'ylim', [ min([cue.y]) - 2, max([cue.y]) + 2 ], 'YAxisLocation', 'right', 'ycolor', [1 0 0] ) ];
				cstep = 255*255*255 / size(groupCuePos,2);	% color step for plot
				for( k = 1 : size(groupCuePos,2) )
					cueTrials = groupTrials( [groupCue.x] == groupCuePos(1,k) & [groupCue.y] == groupCuePos(2,k) );
					data = zeros( size(cueTrials,2), 1201 );
					for( m = 1 : size(cueTrials,2) )
						data(m,:) = cueTrials(m).LFP( round( cueTrials(m).cue.tOn * 1000 ) - 600 : round( cueTrials(m).cue.tOn * 1000 ) + 600 );
					end
					meanData = mean(data,1);
					colour = [ mod( (k-1)*cstep, 255 )/255, mod( floor((k-1)*cstep/255), 255 )/255, (k-1)*cstep/255/255/255 ];					
					h(k) = plot( ax(1), -600:600, meanData, 'LineWidth', 2, 'color', colour, 'DisplayName', sprintf( '[%d,%d]', groupCuePos(1,k), groupCuePos(2,k) ) );
					plot( ax(2), groupCuePos(1,k), groupCuePos(2,k), '*', 'MarkerSize', 15, 'color', colour );
				end
				title( num2str(groupCuePos) );
				legend(h);
				set( gcf, 'CurrentAxes', ax(1) );
			end

		end
	end
	

end