classdef BlocksAnalyzer < handle

	properties
		blocks		= RexBlock();
		nBlocks		= 0;
		nTrials		= 0;
		nCorrect	= 0;
		nError		= 0;
		nFixbreak	= 0;
		nAbort		= 0;
		nUnknown	= 0;
		performance = [];
	end

	methods
		function obj = BlocksAnalyzer( blockClass, fileNames, fieldFlags )
			if( nargin() <= 1 )
				obj.blocks = [];
				return;
			end
			if( nargin() == 2 )
				fieldFlags = DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX;
			end
			if( isempty(blockClass) )
				blockClass = 'RexBlock';
			end

			obj.nBlocks = size( fileNames, 1 );
			if( obj.nBlocks < 1 )
				obj.blocks = [];
				return;
			end
			eval( [ 'obj.blocks = ', blockClass, '();' ] );
			eval( [ 'obj.blocks(obj.nBlocks) = ', blockClass, '();' ] );
			i = 1;
			for( j = 1 : obj.nBlocks )
				eval( [ 'obj.blocks(i) = ', blockClass, '( [], fileNames(j,:), RexBlock.REFINED_FILE, fieldFlags );' ] );
				if obj.blocks(i).nTrials == 0
					continue;
				end
				obj.nTrials = obj.nTrials + obj.blocks(i).nTrials;
				obj.nCorrect = obj.nCorrect + obj.blocks(i).nCorrect;
				obj.nError = obj.nError + obj.blocks(i).nError;
				obj.nFixbreak = obj.nFixbreak + obj.blocks(i).nFixbreak;
				obj.nAbort = obj.nAbort + obj.blocks(i).nAbort;
				obj.nUnknown = obj.nUnknown + obj.blocks(i).nUnknown;
				obj.performance(i).correct = double(obj.blocks(i).nCorrect) / double(( obj.blocks(i).nCorrect + obj.blocks(i).nError ));
				obj.performance(i).break = double(obj.blocks(i).nFixbreak) / double( obj.blocks(i).nFixbreak + obj.blocks(i).nCorrect + obj.blocks(i).nError );
				i = i + 1;
			end
			obj.blocks(i:end) = [];
			obj.nBlocks = i - 1;
		end

		function ShowPerformance( obj, iFirst, iLast, condition, path )
			%% show correct and fixbreak ratioes
			%  distribution of saccades reaction time
			%  Usage: obj.ShowPerformance( [ iFirst=1, iLast=end, condition='all', path=[] ] )
			%    path: specify the folder to save the figure; if not given, the figure will not be saved

			if( nargin() == 1 )
				iFirst = 1;
			end
			if( nargin() <= 2 )
				iLast = obj.nBlocks;
			end
			if( nargin() <= 3 )
				condition = 'all';
			end
			if( nargin() <= 4 )
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

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'performance_blocks[', num2str(iFirst), ',', num2str(iLast), ']_', condition ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
		 	
		 	subplot(1,2,1);
			plot( [ obj.performance(iFirst:iLast).correct ], 'g', 'LineWidth', 3, 'Marker', '*' );
			hold on;
			plot( [ obj.performance(iFirst:iLast).break ], 'r', 'LineWidth', 3, 'Marker', '*' );
			% set( gca, 'xlim', [ iFirst-0.5, iLast+0.5 ], 'xtick', iFirst:iLast );
			legend( 'correct', 'break', 'location', 'East' );
			xlabel( 'Block number', 'FontSize', 12 );
			ylabel( 'Percentage (%)', 'FontSize', 12 );

			latency = zeros( 3, obj.nTrials ); % correct, error, fixbreak
			index = [ 0 0 0 ];
			for( i = iFirst : iLast )
				tj1 = obj.blocks(i).GetTFromFp( REX_CODE_MAP.JMP1ON );
				for j = 1 : obj.blocks(i).nTrials
					if( obj.blocks(i).trials(j).type == TRIAL_TYPE_DEF.UNKNOWN ), continue; end

					switch condition
						case 'all'
							isSelected = true;
						case 'left'
							isSelected = obj.blocks(i).trials(j).cue.x < 0;
						case 'right'
							isSelected = obj.blocks(i).trials(j).cue.x > 0;
						otherwise
							isSelected = true;
					end

					if( obj.blocks(i).trials(j).type == TRIAL_TYPE_DEF.FIXBREAK && obj.blocks(i).trials(j).fp.tOn > 0 )	% break trial
						tmp = obj.blocks(i).trials(j).GetBreak() - obj.blocks(i).trials(j).fp.tOn - tj1;
						index(3) = index(3) + 1;
						latency(3,index(3)) = tmp;
					elseif( ~isempty( obj.blocks(i).trials(j).iResponse1 ) && isSelected )
						tmp = obj.blocks(i).trials(j).saccades( obj.blocks(i).trials(j).iResponse1 ).latency...
								  - obj.blocks(i).trials(j).jmp1.tOn;
						if( obj.blocks(i).trials(j).type == TRIAL_TYPE_DEF.CORRECT )	% correct trial
							index(1) = index(1) + 1;
							latency(1,index(1)) = tmp;
						elseif( obj.blocks(i).trials(j).type == TRIAL_TYPE_DEF.ERROR )	% error trial
							index(2) = index(2) + 1;
							latency(2,index(2)) = tmp;
						end
                    end
				end
            end
			
			subplot(1,2,2);
			hold on;
			
			hist( latency(1,1:index(1)), min(latency(1,1:index(1))) - 0.005 : 0.01 : max(latency(1,1:index(1))) + 0.005 );			
			[data, ax] = hist( latency(2,1:index(2)), min(latency(2,1:index(2))) - 0.005 : 0.01 : max(latency(2,1:index(2))) + 0.005 );
			h = bar(ax,-data,1);
			hist( latency(3,1:index(3)), min(latency(3,1:index(3))) - 0.005 : 0.01 : max(latency(3,1:index(3))) + 0.005 );
			set( gca, 'xlim', [-1.4,0.4] );

			hs = findobj(gca,'type','patch');
			set( hs(2), 'LineStyle', 'none', 'FaceColor', 'g' );
			set( hs(3), 'LineStyle', 'none', 'FaceColor', 'r');
			set( hs(1), 'LineStyle', 'none', 'FaceColor', 'b', 'FaceAlpha', 0.7 );
			legend( hs([2,3,1]), 'correct', 'error', 'fixbreak' );

			xlabel( 'latency' );
			ylabel( 'number of trials' );

			if( nargin == 2 && ~isempty(path) )
				if( path(end) ~= '\' && path(end) ~= '/' )
					path(end+1) = '/';
				end
				if( exist( path, 'dir' ) ~= 7 )
					mkdir( path );
				end 
				saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.fig'  ] );
				saveas( gcf, [ path, num2str(obj.nBlocks), 'blocks_', get(gcf,'Name'), '.bmp'  ] );
			end
		end

		function MainSequence( obj, path, properties, newFigure )
			%% Usage: obj.MainSequence( [ path=[], properties='b.', newFigure=true ] )
			if( nargin() == 1 )
				path = [];
			end
			if( nargin() <= 2 )
				properties = 'b.';
			end
			if( nargin() <= 3 )
				newFigure = true;
			end

			if newFigure
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'MainSequence' );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
			end

			for i = 1 : obj.nBlocks
				obj.blocks(i).MainSequence( properties, false, false );
			end

			xlabel( 'amplitude (log)' );
			ylabel( 'peak velocity (log)' );

			if ~isempty(path)
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

		function MainSeqDensity( obj, path, newFigure, msd_handle, step, c_map )
			%% Usage: obj.MainSeqDensity( [ path=[], newFigure=true, mad_handle=[], step=0.01, c_map='hot' ] )
			if( nargin() == 1 )
				path = [];
			end
			if( nargin() <= 2 )
				newFigure = true;
			end
			if( nargin() <= 3 )
				msd_handle = [];
			end
			if( nargin() <= 4 )
				step = 0.01;
			end
			if( nargin() <= 5 )
				c_map = 'hot';
			end

			if newFigure
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'MainSeqDensity' );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
			 	jf.setMaximized(1);
			end

			h = [];
			for i = 1 : obj.nBlocks
				h = obj.blocks(i).MainSeqDensity( false, h, 0.025, 'hot' );
			end

			xlabel( 'amplitude (log)' );
			ylabel( 'peak velocity (log)' );

			if ~isempty(path)
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

end