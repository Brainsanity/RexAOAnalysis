classdef MyMethods < handle
	
	methods ( Access = private )
		function obj = MyMethods();
		end
	end

	methods ( Static )
		function sc = main( folder1 )
			% for( i = 1 : size(ampEdges,2) - 1 )
			% 	MyMethods.ShowPopulation( folder1, monkey, ampEdges(i:i+1) );
			% 	saveas( gcf, [ folder1, '\', get( gcf, 'name' ), '.bmp' ] );
			% 	saveas( gcf, [ folder1, '\', get( gcf, 'name' ), '.fig' ] );
			% 	close;
			% end
			% return;

			folders2 = ToolKit.ListFolders(folder1);
			minTrialIndex = 1;
			for( i = 1 : size(folders2,1) )
				% folders3 = ToolKit.ListFolders( folders2(i,:) );
				% for( j = 1 : size(folders3,1) )
					% microSacs = MyMethods.ExtractMicroSacs( ToolKit.RMEndSpaces( folders3(j,:) ), minTrialIndex );
					microSacs = MyMethods.ExtractMicroSacs( ToolKit.RMEndSpaces( folders2(i,:) ), minTrialIndex );
					if( ~isempty(microSacs) ) minTrialIndex = microSacs(end).trialIndex + 1; end
				% end
			end
		end

		function ShowChangeIndex( ChangeIndex, label, position, newFigure )
			% position: in unit of panels
			if( nargin() < 1 || nargin() > 4 )
				disp( 'Usage: ShowChangeIndex( ChangeIndex, label, position = [1 1] newFigure = true )' );
			end
			if( nargin() < 2 ) label = 'ChangeIndex'; end
			if( nargin() < 3 ) position = [1 1]; end
			if( nargin() < 4 ) newFigure = true; end
			% load( 'D:\data\cue_task_refinedmat\abao\cue\oblique\ChangeIndex.mat', 'ObliqueChangeIndex' );
			% load( 'D:\data\cue_task_refinedmat\abao\cue\trained\ChangeIndex.mat', 'AbaoChangeIndex' );
			% load( 'D:\data\cue_task_refinedmat\datou\cue\trained\ChangeIndex.mat', 'DatouChangeIndex' );


			w = 4; W = 5*w;	% w for the width of a number, W for the the width of a panel
			h = 2; H = 6*h; % h for the height of a number, H for the height of a panel
			marginx = 0.5*w;
			marginy = 4*h;
			nColumns = fix( 100/W );
			nRows = fix( 100/H );

			if( newFigure )
				set( figure, 'color', 'w', 'NumberTitle', 'off', 'Name', 'ChangeIndex' );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
				jf.setMaximized(1);
				axes( 'visible', 'off', 'ylim', [0 100], 'xlim', [0 100], 'position', [0 0 1 1] );
				hold on;
			end

			corner.x = ( position(1) - 1 ) * W + marginx;
			corner.y = 100 - ( position(2) - 1 ) * H - marginy;

			text( corner.x, corner.y + 0.5*marginy, label, 'HorizontalAlign', 'left', 'VerticalAlign', 'middle', 'FontSize', 15 )

			corner.x = corner.x - W;

			LineColor = [0 1 0];
			FontSize  = 10;
			for( i = 1 : size(ChangeIndex,2) )
				corner.x = corner.x + W;
				if( corner.x - 0.5*w + W > 100 )
					corner.x = 0.5*w;
					corner.y = corner.y - 2 * H - 3*h;
				end

				x = corner.x;
				y = [ corner.y, corner.y-H ];
				fields = {'up', 'down'};

				for( j = 1 : 2 )		
					plot( [ x, x + 4*w ], [ y(j) - 2*h, y(j) - 2*h ], ':', 'color', LineColor );
					plot( [ x + w, x + 3*w ], [ y(j) - 3*h, y(j) - 3*h ], ':', 'color', LineColor );
					plot( [ x, x + 4*w ], [ y(j) - 4*h, y(j) - 4*h ], ':', 'color', LineColor );
					plot( [ x + w, x + w ], [ y(j) - h, y(j) - 5*h ], ':', 'color', LineColor );
					plot( [ x + 2*w, x + 2*w ], [ y(j) - 2*h, y(j) - 4*h ], ':', 'color', LineColor );
					plot( [ x + 3*w, x + 3*w ], [ y(j) - h, y(j) - 5*h ], ':', 'color', LineColor );

					text( x, y(j), [ ChangeIndex(i).name, '\_', fields{j} ], 'HorizontalAlign', 'left', 'VerticalAlign', 'top' );
					text( x + 0.5*w, y(j) - 3*h, num2str( round( ChangeIndex(i).quarter23.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 1.5*w, y(j) - 2.5*h, num2str( round( ChangeIndex(i).quarter2.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 1.5*w, y(j) - 3.5*h, num2str( round( ChangeIndex(i).quarter3.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 2*w, y(j) - 1.5*h, num2str( round( ChangeIndex(i).quarter12.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 2*w, y(j) - 4.5*h, num2str( round( ChangeIndex(i).quarter34.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 2.5*w, y(j) - 2.5*h, num2str( round( ChangeIndex(i).quarter1.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 2.5*w, y(j) - 3.5*h, num2str( round( ChangeIndex(i).quarter4.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
					text( x + 3.5*w, y(j) - 3*h, num2str( round( ChangeIndex(i).quarter41.(fields{j})(1)*10 )/10 ), 'HorizontalAlign', 'center', 'VerticalAlign', 'middle', 'FontSize', FontSize );
				end
			end
		end

		function PlotChangeIndex( ChangeIndex, fd, content, nameX, monkey )
			%%
			% fd:		'k', 'r', 'p', 'ratio', 'num'
			% content: 'up', 'up_StartPoint', 'up_EndPoint', 'down', 'down_StartPoint', 'down_EndPoint'
			% namex:   whether use names as the ticks of x axes

			fds = { 'quarter1', 'quarter2', 'quarter3', 'quarter4', 'quarter12', 'quarter23', 'quarter34', 'quarter41' };
			indices = { 1:8, 1:4, [5 7], [6 8] };
			colors = { 'r', 'g', 'b', 'c', 'm', 'k', 'y', [0.5 0.5 0.5] };
			if( content(1:2) == 'up' ), updown = 'up';
			elseif( content(1:4) == 'down' ), updown = 'down';
			else return; end

			figure; hold on;
			set( gcf, 'NumberTitle', 'off', 'name', [ fd, '_', content ] );
			for( k = 1 : 4 )
				subplot(2,2,k); hold on;
				for( i = indices{k} )
					quarter = [ChangeIndex.(fds{i})];
					data = [quarter.(fd)];
					data = [data.(updown)];
					if( strfind( content, 'Start' ) )
						b = [quarter.b];
						data = data .* tStart + [b.(updown)];
					elseif( strfind( content, 'End' ) )
						b = [quarter.b];
						data = data .* 0.5 + [b.(updown)];
					end
					if( nameX )
						x = sscanf( [ChangeIndex.name], repmat( '%f', 1, length(ChangeIndex) ) );
						x = round(x);				
						plot( x, data, 'color', colors{i}, 'marker', '*' );
					else
						plot( [1:length(ChangeIndex)], data, 'color', colors{i}, 'marker', '*' );
					end
				end
				if( nameX ), set( gca, 'xtick', x(end:-1:1), 'xlim', [ x(end)-2, x(1) + 2 ] ); end
				if( size(content,2) > 4 )
					if( strcmp( updown, 'up' ) ), set( gca, 'ylim', [0 180] );
					else set( gca, 'ylim', [-180 0] ); end
				end
				hold off;
			end
			set( gcf, 'CurrentAxes', axes( 'unit', 'normalized', 'position', [0 0 1 1], 'visible', 'off', 'NextPlot', 'add', 'hittest', 'off' ) );
			handles = [];
			for( i = 1 : 8 )
				handles(end+1) = plot( 0, 0, 'color', colors{i}, 'marker', '*', 'DisplayName', fds{i} );
			end
			legend( handles, 'location', 'NorthWest' );
			ToolKit.BorderText( 'InnerTop', [ fd, '_', content ], 'FontSize', 13, 'interpreter', 'none' );
			ToolKit.BorderText( 'InnerTopRight', monkey, 'FontSize', 13, 'interpreter', 'none' );
		end

		function [ left, right ] = PlotBreakBeforeCue( BreakBeforeCue, oneByOne, ang_step, ang_win )
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 15; end

			if( oneByOne )
				bbc = BreakBeforeCue;
			else
				bbc.name = sprintf( [ repmat( '%s,', 1, size(BreakBeforeCue,2)-1 ), '%s' ], BreakBeforeCue.name );
				bbc.angles = [BreakBeforeCue.angles];
			end
			for( i = 1:size(bbc,2) )
				angles = bbc(i).angles;

				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', [ 'BreakBeforeCue_', bbc(i).name ] );
				subplot(2,2,[1 3]);
				polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
				title( 'Direction distribution of break saccades before cue on', 'FontSize', 12 );
				
				subplot(2,2,2);
				[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
				bar( ax, data/sum(data), 1, 'g' );
				set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
				xlabel( 'Break direction (\circ)', 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );

				left(i) = sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2);
				right(i) = sum( -ang_win < angles & angles < ang_win ) / size(angles,2);
				subplot(2,2,4); hold on;
				bar( 1, left(i), 0.5, 'g' );
				text( 1, 0, 'left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, right(i), 0.5, 'r' );
				text( 2, 0, 'right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
			index = isnan( left ) | isnan(right);
			left(index) = [];
			right(index) = [];
			if( oneByOne )
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'BreakBeforeCue_Dots_Statistical' );

				subplot(1,2,1);
				hold on;
				plot( left, right, 'k:*' );
				% plot( left(1:10), right(1:10), 'r:' );
				plot( left(1), right(1), 'r*' );
				% plot( left(11:end), right(11:end), 'b:' );
				% plot( left(11), right(11), 'b*' );

				axis('equal');
				set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
				x = get(gca,'xlim');
				y = get(gca,'ylim');
				plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'K:' );

				xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
				ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );

				subplot(1,2,2);
				hold on;
				bar( 1, mean(left), 0.5, 'g' );
				errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'left' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		function SCBias = SCBiasAnalyzer( folder, monkey, isOblique, ang_step, ang_win )
			if( nargin() < 3 ), isOblique = false; end
			if( nargin() < 4 ), ang_step = 10; end
			if( nargin() < 5 ), ang_win = 20; end

			if( exist( [folder,'\..\SCBias.mat'], 'file' ) == 2 )
				load( [folder,'\..\SCBias.mat'] );				
			else
				SCBias = [];
				years = ToolKit.ListFolders( folder );
				for( iYear = 1 : size(years,1) )
					months = ToolKit.ListFolders( ToolKit.RMEndSpaces(years(iYear,:)) );
					for( iMonth = 1 : size(months,1) )
						month = ToolKit.RMEndSpaces(months(iMonth,:));
						SCBias(end+1).name = month( find( month == '\', 1, 'last' ) + 1 : end );
						
						sc = SCueBlocksAnalyzer( ToolKit.ListMatFiles(month) );
						
						SCBias(end).fp2rf.angles	= [];	% angles for breaks after fixation point on before candidate targets on
						SCBias(end).fp2rf.time		= [];	% break time aligned to fp on
						SCBias(end).rf2cue.angles	= [];	% angles for breaks after candidate targets on before cue on
						SCBias(end).rf2cue.time		= [];	% break time aligned to rf on
						SCBias(end).cue2j1.tarLeft.angles	= [];	% angles for breaks after cue on when target is on the left side
						SCBias(end).cue2j1.tarLeft.ePoints	= [];	% saccade end points
						SCBias(end).cue2j1.tarLeft.time		= [];	% break time aligned to cue on
						SCBias(end).cue2j1.tarRight.angles	= [];	% angles for breaks after cue on when target is on the right side
						SCBias(end).cue2j1.tarRight.ePoints	= [];	% saccade end points
						SCBias(end).cue2j1.tarRight.time	= [];	% break time alinged to cue on
						SCBias(end).errors.tarLeft.angles	= [];	% angles for errors when target is on the left side
						SCBias(end).errors.tarLeft.ePoints	= [];	% saccade end points
						SCBias(end).errors.tarLeft.time		= [];	% saccade time aligned to jmp1 on
						SCBias(end).errors.tarRight.angles 	= [];	% angles for errors when target i on the right side
						SCBias(end).errors.tarRight.ePoints	= [];	% saccade end points
						SCBias(end).errors.tarRight.time	= [];	% saccade time aligned to jmp1 on
						SCBias(end).nLeftBreaks		= 0;
						SCBias(end).nRightBreaks	= 0;
						SCBias(end).nLeftErrors		= 0;
						SCBias(end).nRightErrors	= 0;
						SCBias(end).nLeftCorrect	= 0;
						SCBias(end).nRightCorrect	= 0;
						for( iBlock = sc.nBlocks : -1 : 1 )
							if( ~isOblique && any( sc.blocks(iBlock).blockName == 's' ) ) continue; end
							breaks = sc.blocks(iBlock).trials( [sc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
							if( ~isempty(breaks) )
								%% for SCBias(end).fp2rf
								fp = [breaks.fp];
								rf = [breaks.rf];
								trials = breaks( [fp.tOn] > 0 & [rf.tOn] < 0 );
								if( ~isempty(trials) )
									[ tBreak, breakSacs ] = trials.GetBreak();
									fp = [trials.fp];
									% tIndex = tBreak > [fp.tOn] + 0.25;	% tmp index of breaks 250ms after fp on
									SCBias(end).fp2rf.angles = [ SCBias(end).fp2rf.angles, [breakSacs.angle] ];
									SCBias(end).fp2rf.time = [ SCBias(end).fp2rf.time, tBreak - [fp.tOn] ];
								end

								%% for SCBias(end).rf2cue
								rf = [breaks.rf];
								cue = [breaks.cue];
								trials = breaks( [rf.tOn] > 0 & [cue.tOn] < 0 );
								if( ~isempty(trials) )
									[ tBreak, breakSacs ] = trials.GetBreak();
									SCBias(end).rf2cue.angles = [ SCBias(end).rf2cue.angles, [breakSacs.angle] ];
									rf = [trials.rf];
									SCBias(end).rf2cue.time = [ SCBias(end).rf2cue.time, tBreak - [rf.tOn] ];
								end

								%% for SCBias(end).cue2j1
								cue = [breaks.cue];
								jmp1 = [breaks.jmp1];
								trials = breaks( [cue.tOn] > 0 & [jmp1.tOn] < 0 );
								if( ~isempty(trials) )
									cue = [trials.cue];
									
									%% for target left condition
									[ tBreak, breakSacs ] = trials( [cue.x] < 0 ).GetBreak;
									SCBias(end).cue2j1.tarLeft.angles = [ SCBias(end).cue2j1.tarLeft.angles, [breakSacs.angle] ];
									ePoints = [breakSacs.termiPoints];
                                    if( ~isempty(ePoints) )
                                        SCBias(end).cue2j1.tarLeft.ePoints = [ SCBias(end).cue2j1.tarLeft.ePoints, ePoints(:,2) ];
                                    end
									SCBias(end).cue2j1.tarLeft.time = [ SCBias(end).cue2j1.tarLeft.time, tBreak - [ cue( [cue.x] < 0 ).tOn ] ];
									SCBias(end).nLeftBreaks = SCBias(end).nLeftBreaks + sum( [cue.x] < 0 );

									%% for target right condition
									[ tBreak, breakSacs ] = trials( [cue.x] > 0 ).GetBreak;
									SCBias(end).cue2j1.tarRight.angles = [ SCBias(end).cue2j1.tarRight.angles, [breakSacs.angle] ];
									ePoints = [breakSacs.termiPoints];
                                    if( ~isempty(ePoints) )
                                        SCBias(end).cue2j1.tarRight.ePoints = [ SCBias(end).cue2j1.tarRight.ePoints, ePoints(:,2) ];
                                    end
									SCBias(end).cue2j1.tarRight.time = [ SCBias(end).cue2j1.tarRight.time, tBreak - [ cue( [cue.x] > 0 ).tOn ] ];
									SCBias(end).nRightBreaks = SCBias(end).nRightBreaks + sum( [cue.x] > 0 );
								end
							end

							%% for SCBias(end).errors
							trials = sc.blocks(iBlock).trials( [sc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.ERROR );
							if( ~isempty(trials) )
								jmp1 = [trials.jmp1];
								SCBias(end).nLeftErrors = SCBias(end).nLeftErrors + sum( [jmp1.x] < 0 );
								SCBias(end).nRightErrors = SCBias(end).nRightErrors + sum( [jmp1.x] > 0 );
								j1win = 2.5;
								for( trial = trials )
									endPoint = trial.saccades(trial.iResponse1).termiPoints(:,2);
									% if( ~inpolygon( endPoint(1), endPoint(2), [ -j1win j1win j1win -j1win -j1win ] + trial.jmp1.x, [ -j1win -j1win j1win j1win -j1win ] + trial.jmp1.y ) )
										if( trial.jmp1.x < 0 )
											SCBias(end).errors.tarLeft.angles = [ SCBias(end).errors.tarLeft.angles, trial.saccades(trial.iResponse1).angle ];
											SCBias(end).errors.tarLeft.ePoints = [ SCBias(end).errors.tarLeft.ePoints, trial.saccades(trial.iResponse1).termiPoints(:,2) ];
											SCBias(end).errors.tarLeft.time = [ SCBias(end).errors.tarLeft.time, trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn ];
										elseif( trial.jmp1.x > 0 )
											SCBias(end).errors.tarRight.angles = [ SCBias(end).errors.tarRight.angles, trial.saccades(trial.iResponse1).angle ];
											SCBias(end).errors.tarRight.ePoints = [ SCBias(end).errors.tarRight.ePoints, trial.saccades(trial.iResponse1).termiPoints(:,2) ];
											SCBias(end).errors.tarRight.time = [ SCBias(end).errors.tarRight.time, trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn ];
										end
									% end
								end
							end

							%% for correct
							trials = sc.blocks(iBlock).trials( [sc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT );
							if( ~isempty(trials) )
								jmp1 = [trials.jmp1];
								SCBias(end).nLeftCorrect = SCBias(end).nLeftCorrect + sum( [jmp1.x] < 0 );
								SCBias(end).nRightCorrect = SCBias(end).nRightCorrect + sum( [jmp1.x] > 0 );
							end
						end
						if( SCBias(end).nLeftCorrect == 0 && SCBias(end).nRightCorrect == 0 ) SCBias(end) = []; end

					end
				end
				save( [folder,'\..\SCBias.mat'], 'SCBias' );
			end

			%% fp2rf, rf2cue
			for( k = 1 : 2 )				
				if( k == 1 )
					%% get data
					% for population
					angles = [];
					time = [];
					for( i = 1 : size(SCBias,2) )
						time = [ time, SCBias(i).fp2rf.time ];
						angles = [ angles, SCBias(i).fp2rf.angles( SCBias(i).fp2rf.time > 0.25 ) ];		% only use breaks 250ms after fixation on
					end

					% for significance
					tIndex = false(size(SCBias));
					for( i = size(SCBias,2) : -1 : 1 )
						tAngs = SCBias(i).fp2rf.angles( SCBias(i).fp2rf.time > 0.25 );
						if( isempty(tAngs) )
							tIndex(i) = true;
							continue;
						end
						left(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
						right(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
					end
					left(tIndex) = [];
					right(tIndex) = [];

					%% names, labels...
					figName = [ monkey,' Breaks After Fp On Before Candidates On' ];
					figDirectTitle = 'Direction distribution of break saccades before candidates on';
					figTimeTitle = 'Time distribution of break saccades before candidates on';
				else
					%% get data
					% for population
					angles = [];
					time = [];
					for( i = 1 : size(SCBias,2) )
						time = [ time, SCBias(i).rf2cue.time ];
						angles = [ angles, SCBias(i).rf2cue.angles ];
					end

					% for significance
					tIndex = false(size(SCBias));
					for( i = size(SCBias,2) : -1 : 1 )
						tAngs = SCBias(i).rf2cue.angles;
						if( isempty(tAngs) )
							tIndex(i) = true;
							continue;
						end
						left(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
						right(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
					end
					left(tIndex) = [];
					right(tIndex) = [];					

					%% names, labels...
					figName = [ monkey, ' Breaks After Candidates On Before Cue On' ];
					figDirectTitle = 'Direction distribution of break saccades before cue on';
					figTimeTitle = 'Time distribution of break saccades before cue on';
				end

				FontSize = 30;

				%% figure for population
				set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Population)' ] );

				% time distribution
				subplot(2,2,1);
				t_step = 0.01;
				[data, ax] = hist( time, min(time) - t_step/2 : t_step : max(time) + t_step/2 );
				bar( ax, data/sum(data), 1, 'g' );
				xlabel( 'Break time (s)', 'FontSize', FontSize );
				ylabel( 'Proportion (%)', 'FontSize', FontSize );
				title( figTimeTitle, 'FontSize', FontSize );
				
				% direction polar plot
				subplot(2,2,2);			
				polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
				title( figDirectTitle, 'FontSize', FontSize );

				% direction hist plot
				subplot(2,2,3);
				[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
				bar( ax, data/sum(data), 1, 'g' );
				set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
				xlabel( 'Break direction (\circ)', 'FontSize', FontSize );
				ylabel( 'Proportion (%)', 'FontSize', FontSize );
				title( figDirectTitle, 'FontSize', FontSize );

				% bar comparison
				subplot(2,2,4); hold on;
				bar( 1, sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2), 0.5, 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
				bar( 2, sum( -ang_win < angles & angles < ang_win ) / size(angles,2), 0.5, 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', FontSize );
				ylabel( 'Proportion (%)', 'FontSize', FontSize );

				%% figure for significance
				set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Significance)' ] );

				% dots plot
				subplot(1,2,1); hold on;
				plot( left, right, 'k^', 'MarkerFaceColor', 'k' );
				% plot( left(1), right(1), 'r*' );
				axis('equal');
				set( gca, 'FontSize', FontSize, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
				x = get(gca,'xlim');
				y = get(gca,'ylim');
				plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

				xlabel( 'Proportion of breaks towards left (%)', 'FontSize', FontSize );
				ylabel( 'Proportion of breaks towards right (%)', 'FontSize', FontSize );
				title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', FontSize );

				% significance test
				subplot(1,2,2);	hold on;
				bar( 1, mean(left), 0.5, 'g' );
				errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
				set( gca, 'FontSize', FontSize, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				if( mean(left) < mean(right) )	tail = 'left';
				else 							tail = 'right'; end
				text( 2.7, 0.9, sprintf( 'p = %f\ntail: %s', signrank( left, right, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', FontSize  );
				title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', FontSize );
				ylabel( 'Proportion (%)', 'FontSize', FontSize );

			end

			%% cue2j1 break ratio to all breaks: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			for( i = 1 : size(SCBias,2) )
				time.left = [ time.left, SCBias(i).cue2j1.tarLeft.time ];
				time.right = [ time.right, SCBias(i).cue2j1.tarRight.time ];
				angles.left = [ angles.left, SCBias(i).cue2j1.tarLeft.angles( SCBias(i).cue2j1.tarLeft.time < tBound ) ];
				angles.right = [ angles.right, SCBias(i).cue2j1.tarRight.angles( SCBias(i).cue2j1.tarRight.time < tBound ) ];
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Population)' ] );
			
			% time distribution
			subplot(2,2,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xlim', [0 0.65] )
			xlabel( 'Break time (s)', 'FontSize', FontSize );
			ylabel( 'Proportion (%)', 'FontSize', FontSize );
			title( 'Time distribution of break saccades after cue on', 'FontSize', FontSize );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,2,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', FontSize );
			legend( 'Tar left', 'Tar right' );

			% direction hist plot
			subplot(2,2,3); hold on;
			[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', FontSize );
			ylabel( 'Proportion (%)', 'FontSize', FontSize );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', FontSize );

			% bar comparison
			subplot(2,2,4); hold on;			
			bar( 1, sum( angles.left < -180 + ang_win | angles.left > 180 - ang_win ) / size(angles.left,2), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, sum( -ang_win < angles.right & angles.right < ang_win ) / size(angles.right,2), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 3, sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / size(angles.right,2), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, sum( -ang_win < angles.left & angles.left < ang_win ) / size(angles.left,2), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			title( sprintf( 'Break ratio to all breaks (Window: +-%d\\circ)', ang_win ), 'FontSize', FontSize );
			ylabel( 'Break ratio (%)', 'FontSize', FontSize );

			%% cue2j1 break ratio to all breaks: significance
			% get data
			for( i = size(SCBias,2) : -1 : 1 )
				tAngs = SCBias(i).cue2j1.tarRight.angles( SCBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				tAngs = SCBias(i).cue2j1.tarLeft.angles( SCBias(i).cue2j1.tarLeft.time < tBound );
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', FontSize );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', FontSize );
			title( sprintf('Break ratio to all breaks (Window +-%d\\circ)',ang_win), 'FontSize', FontSize );
			legend(h);

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', FontSize );
			ylabel( 'Break ratio (%)', 'FontSize', FontSize );

			%% cue2j1 break ratio to all trials
			% get data
			nLeftBreaks = sum( [SCBias.nLeftBreaks] );
			nLeftErrors = sum( [SCBias.nLeftErrors] );
			nLeftCorrect = sum( [SCBias.nLeftCorrect] );
			nRightBreaks = sum( [SCBias.nRightBreaks] );
			nRightErrors = sum( [SCBias.nRightErrors] );
			nRightCorrect = sum( [SCBias.nRightCorrect] );
			for( i = size(SCBias,2) : -1 : 1 )
				NLeft(i) = SCBias(i).nLeftBreaks + SCBias(i).nLeftErrors + SCBias(i).nLeftCorrect;		% number of target left trials
				NRight(i) = SCBias(i).nRightBreaks + SCBias(i).nRightErrors + SCBias(i).nRightCorrect;	% number of target right trials
				tAngs = SCBias(i).cue2j1.tarLeft.angles( SCBias(i).cue2j1.tarLeft.time < tBound );
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target left
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target left
				tAngs = SCBias(i).cue2j1.tarRight.angles( SCBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target right
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target right
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Trials After Cue On (Ratio)' ] );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );

			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( sprintf('Break ratio to all trials (Window +-%d\\circ)',ang_win), 'FontSize', FontSize );
			ylabel( 'Break ratio (%)', 'FontSize', FontSize );

			% dots plot
			LL = LL./NLeft;
			RR = RR./NRight;
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,[1 2 4 5]); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', FontSize );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', FontSize );
			title( sprintf('Month by month break ratio (Window +-%d\\circ)',ang_win), 'FontSize', FontSize );
			legend(h);

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 0.1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', FontSize );
			ylabel( 'Break ratio (%)', 'FontSize', FontSize );

			%% errors: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			j1win = 2.5;
			for( i = size(SCBias,2) : -1 : 1 )
				time.left = [ time.left, SCBias(i).cue2j1.tarLeft.time( SCBias(i).cue2j1.tarLeft.time > tBound ) - 0.6, SCBias(i).errors.tarLeft.time ];
				time.right = [ time.right, SCBias(i).cue2j1.tarRight.time( SCBias(i).cue2j1.tarRight.time > tBound ) - 0.6, SCBias(i).errors.tarRight.time ];
				angles.left = [ angles.left, SCBias(i).cue2j1.tarLeft.angles( SCBias(i).cue2j1.tarLeft.time > tBound ), SCBias(i).errors.tarLeft.angles ];
				angles.right = [ angles.right, SCBias(i).cue2j1.tarRight.angles( SCBias(i).cue2j1.tarRight.time > tBound ), SCBias(i).errors.tarRight.angles ];
				
				LL(i) = SCBias(i).nLeftCorrect;
				RR(i) = SCBias(i).nRightCorrect;
				LR(i) = 0;
				RL(i) = 0;
				for( m = 1 : size( SCBias(i).cue2j1.tarLeft.ePoints, 2 ) )
					if( SCBias(i).cue2j1.tarLeft.time(m) > tBound )
						if( inpolygon( SCBias(i).cue2j1.tarLeft.ePoints(1,m), SCBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LL(i) = LL(i) + 1;
						elseif( inpolygon( SCBias(i).cue2j1.tarLeft.ePoints(1,m), SCBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LR(i) = LR(i) + 1;
						end
					end
				end
				for( m = 1 : size( SCBias(i).errors.tarLeft.ePoints, 2 ) )
					if( inpolygon( SCBias(i).errors.tarLeft.ePoints(1,m), SCBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LL(i) = LL(i) + 1;
					elseif( inpolygon( SCBias(i).errors.tarLeft.ePoints(1,m), SCBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LR(i) = LR(i) + 1;
					end
				end
				for( m = 1 : size( SCBias(i).cue2j1.tarRight.ePoints, 2 ) )
					if( SCBias(i).cue2j1.tarRight.time(m) > tBound )
						if( inpolygon( SCBias(i).cue2j1.tarRight.ePoints(1,m), SCBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RL(i) = RL(i) + 1;
						elseif( inpolygon( SCBias(i).cue2j1.tarRight.ePoints(1,m), SCBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RR(i) = RR(i) + 1;
						end
					end
				end
				for( m = 1 : size( SCBias(i).errors.tarRight.ePoints, 2 ) )
					if( inpolygon( SCBias(i).errors.tarRight.ePoints(1,m), SCBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RL(i) = RL(i) + 1;
					elseif( inpolygon( SCBias(i).errors.tarRight.ePoints(1,m), SCBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RR(i) = RR(i) + 1;
					end
				end

			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Error ratio' ] );
			
			% time distribution
			subplot(2,3,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			xlabel( 'Response time (s)', 'FontSize', FontSize );
			ylabel( 'Proportion (%)', 'FontSize', FontSize );
			title( 'Time distribution of predictive saccades and errors', 'FontSize', FontSize );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,3,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of predictive saccades and errors', 'FontSize', FontSize );
			legend( 'Tar left', 'Tar right' );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( 'Correct ratio & Error ratio: Population', 'FontSize', FontSize );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', FontSize );

			% dots plot: LL.VS.RR
			LL = LL./NLeft;
			RR = RR./NRight;
			subplot(2,3,4); hold on;
			plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			axis('equal');
			ymin = min( [ LL, RR ] ) * 0.7;
			ymax = max( [ LL, RR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target left  (%)', 'FontSize', FontSize );
			ylabel( 'Rightward response ratio when target right', 'FontSize', FontSize );
			title( 'Month by month response ratio: LL.VS.RR', 'FontSize', FontSize );

			% dots plot: LL.VS.RR
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,5); hold on;
			plot( RL, LR, 'm:s', 'DisplayName', 'LL.VS.RR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ RL, LR ] ) * 0.7;
			ymax = max( [ RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target right  (%)', 'FontSize', FontSize );
			ylabel( 'Rightward response ratio when target left (%)', 'FontSize', FontSize );
			title( 'Month by month response ratio: RL.VS.LR', 'FontSize', FontSize );

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( 'Correct ratio & Error ratio: Significance test', 'FontSize', FontSize );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', FontSize );

			return;
		end

		function [ left, right ] = PlotBreakAfterCue( BreakAfterCue, oneByOne, ang_step, ang_win, showAll )
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 15; end

			if( oneByOne )
				bac = BreakAfterCue;
			else
				bac.name = sprintf( [ repmat( '%s,', 1, size(BreakAfterCue,2)-1 ), '%s' ], BreakAfterCue.name );
				angles = [BreakAfterCue.angles];
				bac.angles.left = [ angles.left ];
				bac.angles.right = [angles.right];
			end
			for( i = 1:size(bac,2) )
				angles = bac(i).angles;

				if( showAll )
					figure;
					set( gcf, 'NumberTitle', 'off', 'Name', [ 'BreakAfterCue_', bac(i).name ] );
					subplot(2,2,[1 3]);
					polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
					hold on;
					polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
					title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );
					
					subplot(2,2,2); hold on;
					[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
					h = bar( ax, data/sum(data), .5, 'g' );
					[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
					h = bar( ax+ang_step/2, data/sum(data), .5, 'r' );
					% set( h, 'LineStyle', 'none', 'FaceColor', 'g' );
					set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
					xlabel( 'Break direction (\circ)', 'FontSize', 12 );
					ylabel( 'Proportion (%)', 'FontSize', 12 );
				end

				left(i) = sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / size(angles.right,2);
				right(i) = sum( -ang_win < angles.left & angles.left < ang_win ) / size(angles.left,2);

				if( showAll )
					subplot(2,2,4); hold on;
					bar( 1, left(i), 0.5, 'g' );
					text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
					bar( 2, right(i), 0.5, 'r' );
					text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
					set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
					title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
					ylabel( 'Proportion (%)', 'FontSize', 12 );
				end
			end
			index = isnan( left ) | isnan(right);
			left(index) = [];
			right(index) = [];
			if( oneByOne )
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'BreakAfterCue_Dots_Statistical' );

				subplot(1,2,1);
				hold on;
				nTraining = 9;	% for abao
				nTraining = 10;	% for datou
				plot( left, right, 'k*' );
				% plot( left, right, 'k:');
				plot( left(1:1), right(1:1), 'b*' );
				plot( left(1:nTraining), right(1:nTraining), 'r:' );
				plot( left(1:1), right(1:1), 'r*' );
				plot( left(nTraining+1:end), right(nTraining+1:end), 'b:' );
				plot( left(nTraining+1), right(nTraining+1), 'b*' );
				
				axis('equal');
				set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
				x = get(gca,'xlim');
				y = get(gca,'ylim');
				plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'K:' );

				xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
				ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );

				subplot(1,2,2);
				hold on;
				bar( 1, mean(left), 0.5, 'g' );
				errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'left' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		function [ left, right ] = PlotErrorDirection( ErrorDirection, oneByOne, ang_step, ang_win, showAll )
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 15; end
			if( nargin() < 5 ), showAll = false; end

			if( oneByOne )
				ed = ErrorDirection;
			else
				ed.name = sprintf( [ repmat( '%s,', 1, size(ErrorDirection,2)-1 ), '%s' ], ErrorDirection.name );
				data = [ErrorDirection.data];
				dataleft = [data.left];
				dataright = [data.right];
				ed.data.left.errorAngles = [dataleft.errorAngles];
				ed.data.left.breakAngles = [dataleft.breakAngles];
				ed.data.left.nCorrect = sum( [dataleft.nCorrect] );
				ed.data.left.nError = sum( [dataleft.nError] );
				ed.data.left.nFixbreak = sum( [dataleft.nFixbreak] );
				ed.data.right.errorAngles = [dataright.errorAngles];
				ed.data.right.breakAngles = [dataright.breakAngles];
				ed.data.right.nCorrect = sum( [dataright.nCorrect] );
				ed.data.right.nError = sum( [dataright.nError] );
				ed.data.right.nFixbreak = sum( [dataright.nFixbreak] );
			end
			for( i = 1:size(ed,2) )
				data = ed(i).data;
				leftAngles = [ data.left.errorAngles];%, data.left.breakAngles ];
				nLeftTrials = data.left.nCorrect + data.left.nError;% + data.left.nFixbreak;
				rightAngles = [ data.right.errorAngles];%, data.right.breakAngles ];
				nRightTrials = data.right.nCorrect + data.right.nError;% + data.right.nFixbreak;

				if( showAll )
					figure;
					set( gcf, 'NumberTitle', 'off', 'Name', [ 'ConditionedErrorDirection', ed(i).name ] );
					subplot(2,2,[1 3]);
					polar( (-180:180)/180*pi, hist( leftAngles, -180:180 ), 'g' );
					hold on;
					polar( (-180:180)/180*pi, hist( rightAngles, -180:180 ), 'r' );
					title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );
					
					subplot(2,2,2); hold on;
					[cdata, ax] = hist( leftAngles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
					bar( ax, cdata/sum(cdata), .5, 'g' );
					[cdata, ax] = hist( rightAngles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
					bar( ax+ang_step/2, cdata/sum(cdata), .5, 'r' );
					set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
					xlabel( 'Break/error direction (\circ)', 'FontSize', 12 );
					ylabel( 'Proportion (%)', 'FontSize', 12 );
				end

				left(i) = sum( rightAngles < -180 + ang_win | rightAngles > 180 - ang_win ) / nRightTrials;
				right(i) = sum( -ang_win < leftAngles & leftAngles < ang_win ) / nLeftTrials;

				if( showAll )
					subplot(2,2,4); hold on;
					bar( 1, left(i), 0.5, 'g' );
					text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
					bar( 2, right(i), 0.5, 'r' );
					text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
					set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
					title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
					ylabel( 'Proportion (%)', 'FontSize', 12 );
				end
			end
			index = isnan( left ) | isnan(right);
			left(index) = [];
			right(index) = [];
			if( oneByOne )
				figure;
				set( gcf, 'NumberTitle', 'off', 'Name', 'ConditionedErrorDirection_Dots_Statistical' );

				subplot(1,2,1);
				hold on;
				nTraining = 9;	% for abao
				nTraining = 10;	% for datou
				plot( left, right, 'k:*' );
				plot( left(1), right(1), 'b*' );
				% plot( left(1:nTraining), right(1:nTraining), 'r:' );
				% plot( left(1:1), right(1:1), 'r*' );
				% plot( left(nTraining+1:end), right(nTraining+1:end), 'b:' );
				% plot( left(nTraining+1), right(nTraining+1), 'b*' );
				plot( [0 1], [0 1], 'K:' );

				axis('equal');
				set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
				x = get(gca,'xlim');
				y = get(gca,'ylim');
				plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'K:' );
				
				xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
				ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );

				subplot(1,2,2);
				hold on;
				bar( 1, mean(left), 0.5, 'g' );
				errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'both' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		function PlotReactionTime( RT, oneByOne )
			if( oneByOne )
				rt = RT;
			else
				rt.name = sprintf( [ repmat( '%s,', 1, size(RT,2)-1 ), '%s' ], RT.name );
				rt.left = [RT.left];
				rt.right = [RT.right];
			end
			
		 	colors = 'gr';
		 	t_step = 0.01;

		 	if( size(rt,2) < 5 ), nColums = size(rt,2);
		 	else nColums = 5; end
		 	nRows = ceil( size(rt,2) / nColums );
		 	figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'ReactionTime' );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
			for( iPanel = 1 : size(rt,2) )
				subplot( nRows, nColums, iPanel ); hold on;
				title(gca,rt(iPanel).name,'interpreter','none');
				data{2} = rt(iPanel).right;
				data{1} = rt(iPanel).left;
			 	for( i = 2 : -1 : 1 )
			 		[cdata, ax] = hist( data{i}, min(data{i}) - t_step/2 : t_step : max(data{i}) + t_step );
					h(i) = bar( ax, cdata/sum(cdata), 1 );
					set( h(i), 'LineStyle', 'none', 'FaceColor', colors(i) );
					set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
		        end
		        set( gca, 'xlim', [-0.2,0.35], 'ylim', [0 0.4] );
			end
			set( gcf, 'CurrentAxes', axes( 'unit', 'normalized', 'position', [0 0 1 1], 'visible', 'off', 'NextPlot', 'add', 'hittest', 'off' ) );
			plot( 0, 0, 'g', 'LineWidth', 10);
			plot( 0, 0, 'r', 'LineWidth', 10);
			legend( 'left', 'right' );
		end

		function sc = PopulationAna( folder )
			sc = folder;
			angs = [];
			for( i = 1 : sc.nBlocks )
				angs = unique( [ angs, sc.blocks(i).GetCueAngles() ] );
			end
			sc = sc.MicrosacFitting( 1, sc.nBlocks, [angs-0.1,181] );
			return;

			while( folder(end) == ' ' ) folder(end) = []; end;
			if( folder(end) ~= '/' && folder(end) ~= '\' )
				folder(end+1) = '\';
			end
			fileNames = ls( folder );
		    if( size(fileNames,1) <= 2 ), return; end;
			fileNames([1 2],:) = [];
			fileNames = [ repmat( folder, size(fileNames,1), 1 ), fileNames ];

			n = 300;
			for( iFile = 1 : n : size(fileNames,1) )
				sc = SCueBlocksAnalyzer( fileNames( iFile : min( iFile+n-1, size(fileNames,1) ), : ) );
			end
		end

		function microSacs = ExtractMicroSacs( folder, minTrialIndex )
			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			sc = SCueBlocksAnalyzer( ToolKit.ListMatFiles(folder) );
			% sc = BlocksAnalyzer( 'MemBlock', ToolKit.ListMatFiles(folder) );	%%%%%% memory
			% sc = BlocksAnalyzer( 'CCueBlock', ToolKit.ListMatFiles(folder) ); %%%%%% color cue
			% sc = BlocksAnalyzer( 'SizePerceptBlock', ToolKit.ListMatFiles(folder) );	%%%%%% size perception
            if( isempty(sc) || sc.nBlocks == 0 || sc.nCorrect == 0 )    microSacs = []; return; end

			fieldNames = {	'latency',...
							'duration',...
							'angle',...
							'amplitude',...
							'termiPoints',...
							'peakSpeed',...
							'name',...
							'trialIndex',...
							'tRf',...
							'tCue',...	%%%%%% spatial cue
							'tJmp1',...
							'rfLoc',...%%%%%% spatial cue & memory & color cue & size perception
							'responseLoc',...%%%%%% size perception
							'responseAngle',...%%%%%% spatial cue
							'responseAmp',...%%%%%% spatial cue
							'responseLat',...%%%%%% spatial cue
							'responsePkVel',...
							'responseDur',...
							...,% 'shape',...%%%%%% size perception
							'cueLoc',...%%%%%% spatial cue
							'tarLoc' };
			for( i = 1 : size(fieldNames,2) )
				microSacs( 4 * sum( [ sc.blocks.nCorrect ] ) ).( fieldNames{i} ) = [];
			end

			count = 1;
			% microSacs(1).trialIndex = minTrialIndex - 1;
			minTrialIndex = minTrialIndex - 1;

			iLastSlash = find( folder == '/' | folder == '\', 2, 'last' );
			% load 'D:\data\cue_task_refinedmat\abao\colorcue\microSacs\suspicion2.mat';	%%%%%% color cue for abao
			for( iBlock = 1 : sc.nBlocks )
				indx = true( size( sc.blocks(iBlock).trials ) );	%%%%%% color cue for abao
				% indx( suspicion2( 2, suspicion2(1,:) == iBlock ) ) = false;	%%%%%% color cue for abao
				trials = sc.blocks(iBlock).trials( [ sc.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT &...
														[ 1, [sc.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] & indx );
				nTrials = size(trials,2);
				for( i = 1 : nTrials )
					sacs0 = trials(i).saccades( 1 : trials(i).iResponse1 - 1 );
					if( isempty(sacs0) ), continue; end
					sacs0( [sacs0.latency] < trials(i).fp.tOn ) = [];
					if( isempty(sacs0) ), continue; end
					sacs = microSacs(1);
					sacs( size(sacs0) ) = microSacs(1);

					latency = num2cell( single( [sacs0.latency] - trials(i).fp.tOn ) );
					[sacs.latency]		= latency{:};
					duration = num2cell( single( [sacs0.duration] ) );
					[sacs.duration]		= duration{:};
					angle = num2cell( single( [sacs0.angle] ) );
					[sacs.angle]		= angle{:};
					amplitude = num2cell( single( [sacs0.amplitude] ) );
					[sacs.amplitude]	= amplitude{:};
					termiPoints = mat2cell( single( [sacs0.termiPoints] ), 2, ones(size(sacs0))*2 );
					[sacs.termiPoints]	= termiPoints{:};
					peakSpeed = num2cell( single( [sacs0.peakSpeed] ) );
					[sacs.peakSpeed]	= peakSpeed{:};
					
					[sacs.name]			= deal( folder( iLastSlash(2) + 1 : end ) );
					[sacs.trialIndex]	= deal( minTrialIndex + i );
					[sacs.tRf]			= deal( trials(i).rf.tOn - trials(i).fp.tOn );
					[sacs.tCue]			= deal( trials(i).cue.tOn - trials(i).fp.tOn );
					[sacs.tJmp1]		= deal( trials(i).jmp1.tOn - trials(i).fp.tOn );
					[sacs.rfLoc]		= deal( [ trials(i).rf.x; trials(i).rf.y ] );%%%%%% memory & color cue
					[sacs.responseLoc]	= deal( trials(i).saccades(trials(i).iResponse1).termiPoints(:,2) );	%%%%%% size perception; spatial cue
					[sacs.responseAmp]	= deal( trials(i).saccades(trials(i).iResponse1).amplitude );	%%%%%% spatial cue
					[sacs.responseAngle]= deal( trials(i).saccades(trials(i).iResponse1).angle );	%%%%%% spatial cue
					[sacs.responseLat]	= deal( trials(i).saccades(trials(i).iResponse1).latency - trials(i).jmp1.tOn ); %%%%%% spatial cue
					[sacs.responsePkVel] = deal( trials(i).saccades(trials(i).iResponse1).peakSpeed );
					[sacs.responseDur]	= deal( trials(i).saccades(trials(i).iResponse1).duration );
					% [sacs.shape]		= deal( trials(i).rf.shape );	%%%%%% size perception
					[sacs.cueLoc]		= deal( [ trials(i).cue.x; trials(i).cue.y ] );	%%%%%% spatial cue
					[sacs.tarLoc]		= deal( [ trials(i).jmp1.x; trials(i).jmp1.y ] );

					microSacs( count + 1 : count + size(sacs,2) ) = sacs;
					count = count + size(sacs,2);
				end
				minTrialIndex = minTrialIndex + nTrials;
			end
			microSacs( [ 1, count+1 : end ] ) = [];
			count = count - 1;
            if( count == 0 ) microSacs = []; return; end

			varname = [ 'microSacs', folder( iLastSlash(2) + 1 : end ) ];
			eval( [ varname, '= microSacs;' ] );
			save( [ folder(1:iLastSlash(2)), varname, '.mat' ], varname );
		end

		function microSacs = LoadMicroSacs( folder )
			fileNames = ToolKit.ListMatFiles( folder );
			s = '[';
			for( i = 1 : size(fileNames,1) )
				load( ToolKit.RMEndSpaces( fileNames(i,:) ) );
				s = [ s, ToolKit.RMEndSpaces( fileNames( i, find( fileNames(i,:) == '\' | fileNames(i,:) == '/', 1, 'last' ) + 1 : end ) ) ];				
				s( end-2 : end ) = [];	% remove ".mat"
				s(end) = ',';
			end
			s(end) = ']';
			eval( [ 'microSacs = ', s, ';' ] );
		end

		function microSacs = Get1stAfter( microSacs, field, t )
			index1 = find( [microSacs.latency] - [microSacs.(field)] > t );
			trialIndex = [microSacs(index1).trialIndex];
			index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
			index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
			trialIndex = [microSacs(index2).trialIndex];
			index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

			microSacs(index2) = [];	% 1st sacs
		end

		function tStart = GetTStart( monkey, task )
			tStart = [];
			if( strcmpi( monkey, 'abao' ) )
            	if( strcmpi( task, 'asc' ) )
            		tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
            	elseif( strcmpi( task, 'cc' ) )
					tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.103 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.106 smoothed with a Gaussian)
				end
			elseif( strcmpi( monkey, 'datou' ) )
				if( strcmpi( task, 'asc' ) )
					tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
				elseif( strcmpi( task, 'cc' ) )
					tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.128 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.124 smoothed with a Gaussian)
				end
			end
		end

		function [edges,data] =  ShowPopulation( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowPopulation( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1.5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			if( strcmp( monkey, 'abao' ) )
				tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
			else
				return;
			end

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );

			cueLoc = [microSacs.cueLoc];
			% microSacs = microSacs( cueLoc(1,:) == 8 & cueLoc(2,:) == 5 );

			respLoc = [microSacs.responseLoc];
			% meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			% meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% % microSacs = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% % microSacs = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );

			%% response saccades accuracy
			centerLX = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			centerLY = mean( respLoc( 2, respLoc(1,:) < 0 ) );
			centerRX = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			centerRY = mean( respLoc( 2, respLoc(1,:) > 0 ) );
			% figure;
			% subplot(1,2,1);
			% hist( sqrt( ( respLoc( 1, respLoc(1,:) < 0 ) - centerLX ) .^ 2 + ( respLoc( 2, respLoc(1,:) < 0 ) - centerLY ) .^ 2 ), 0:0.1:5 );
			% subplot(1,2,2);
			% hist( sqrt( ( respLoc( 1, respLoc(1,:) > 0 ) - centerRX ) .^ 2 + ( respLoc( 2, respLoc(1,:) > 0 ) - centerRY ) .^ 2 ), 0:0.1:5 );
			% return;

			amplitude = [microSacs.responseAmp];
			meanL = mean( amplitude( respLoc(1,:) < 0 ) );
			meanR = mean( amplitude( respLoc(1,:) > 0 ) );
			% microSacs = microSacs( respLoc(1,:) < 0 & amplitude < meanL | respLoc(1,:) > 0 & amplitude < meanR );
			% microSacs = microSacs( respLoc(1,:) < 0 & amplitude > meanL | respLoc(1,:) > 0 & amplitude > meanR );

			% amp_step = 0.1;
			% tarLoc = [microSacs.tarLoc];
			% amplitude = [ microSacs( [microSacs.latency] - [microSacs.tCue] > tStart ).responseAmp ];
			% figure;
			% set( gcf, 'NumberTitle', 'off', 'name', [ 'AmplitudeDistribution_', monkey ] );
			% hist( amplitude, min(amplitude) - amp_step/2 : amp_step : max(amplitude) + amp_step/2 );
			% set( gca, 'xlim', [0 20] );
			% return;

			latency = [microSacs.responseLat];
			lat_step = 0.01;
			% figure;
			% set( gcf, 'NumberTitle', 'off', 'name', [ 'LatencyDistribution_', monkey ] );
			% hist( latency, min(latency) - lat_step/2 : lat_step : max(latency) + lat_step/2 );			
			% return;
			% microSacs = microSacs( latency > 0.1 );

			microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > -.22 );

			index1 = find( [microSacs.latency] - [microSacs.tCue] > tStart );
			trialIndex = [microSacs(index1).trialIndex];
			index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
			index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
			trialIndex = [microSacs(index2).trialIndex];
			index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

			microSacs(index2) = [];	% 1st sacs
			% microSacs([index1,index3]) = [];	% 2nd sacs
			% microSacs = microSacs(index3);

			% microSacs = microSacs( ( strfind( [microSacs.name], '201212' ) + 5 ) / 6 );	% test cue locations

			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tCue] < 0.6 );
			
			n = floor( size(microSacs,2) / 8 );
			% microSacs = microSacs( 7*n+1:end );

			% figure;
			% hist( [microSacs.angle], [-180:5:180] );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', monkey, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

			t_step = 0.01;
			ang_step = 2;

			tarLoc = [microSacs.tarLoc];
			cueLoc = [microSacs.cueLoc];
			index = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0; cueLoc(2,:) > 0; cueLoc(2,:) < 0 ];
			% index = [ 	cueLoc(1,:) < 0 & cueLoc(2,:) > 0;...
			% 			cueLoc(1,:) > 0 & cueLoc(2,:) > 0;...
			% 			cueLoc(1,:) < 0 & cueLoc(2,:) < 0;...
			% 			cueLoc(1,:) > 0 & cueLoc(2,:) < 0 ] & repmat( tarLoc(2,:) == 0, 4, 1 );
			% index = [ cueLoc(1,:) > 0 ];

			%% show raw data
			cmax = 0;	
			% edges = { -0.22 : t_step : 0.6, -180 : ang_step : 180 };
			edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };
			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tCue];
				ang = [microSacs(index(i,:)).angle];
				ang(ang<0) = ang(ang<0) + 360;
				cdata = hist3( [t; ang]', 'edges', edges );
				tmax = max(max(cdata));
				if( cmax < tmax ) cmax = tmax; end
			end
			% cmax = 28;
			% colormap( [ ones(cmax+1,1), repmat( [ 1, ( 1 - (1:cmax)/cmax ) / 1.2 ]', 1, 2 ) ] );
			colormap('hot');
			% cmp = colormap;
			% colormap( cmp( round( [0:cmax] * ( size(cmp,1) - 1 ) / cmax ) + 1, : ) );
			cmp = colormap;
			for( i = 1 : 2)%size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tCue];
				ang = [microSacs(index(i,:)).angle];
				ang( ang < 0 ) = ang( ang < 0 ) + 360;

				subplot(2,2,i); hold on; %caxis([0 10]);
				% edges = { min(t) - t_step/2 : t_step : max(t) + t_step/2, -180 : ang_step : 180 };
				% edges = { -0.9 : t_step : 0.7, -180 : ang_step : 180 };
				%hist3( [t; ang]', 'edges', edges );
				cdata = hist3( [t; ang]', 'edges', edges )';
				% cdata = cdata ./ repmat( max(cdata), size(cdata,1), 1 );
				cdata( isnan(cdata) ) = 0;
	            if( ~isempty(cdata) )
	            	data{i} = cdata;

	                % set( pcolor( edges{1}, edges{2}, cdata ), 'LineStyle', 'none' );
	                colour = cdata/cmax;
	                red = ones(size(cdata)) - cdata/cmax;
	                green = ones(size(red)) - cdata/cmax;
	                green(green<1) = green(green<1)/1.2;
	                blue = green;

	                nColors = size(cmp,1) - 1;
	                colour = reshape( cmp( round( cdata * nColors / cmax ) + 1 , : ), [ size(cdata), 3 ] );
	                % colour = reshape( cmp( round( cdata * nColors ) + 1 , : ), [ size(cdata), 3 ] );
	                image( edges{1}, edges{2}, colour );
	                % image( edges{1}, edges{2}, cat( 3, 1-cdata, 1-cdata, 1-cdata ) );
	            end
	            pause(0.6);
	            % colorbar;
	            % tCMAX = caxis;
	            % if( cmax < tCMAX(2) ) cmax = tCMAX(2); end

	            set( gca, 'layer', 'top', 'color', 'k', 'XColor', 'g', 'YColor', 'g', 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [0:90:360] );
				xlabel( [ 'Time from ', 'cue on (s)' ], 'FontSize', 12 );
				ylabel( [ 'Microsaccades direction (\circ)' ], 'FontSize', 12 );

	            % show -90, 0, 90 degrees
	            for( k = 90 : 90 : 270 )
	            	plot( [ edges{1}(1), edges{1}(end) ], [k k], 'w:' );
	            end

	            % show cue angles
				angs = cart2pol( cueLoc(1,index(i,:)), cueLoc(2,index(i,:)) ) / pi * 180;
				y = zeros( 1, size(angs,2)*3 ) * NaN;
				y( 1 : 3 : end-2 ) = angs;
				y( 2 : 3 : end-1 ) = angs;
				x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
				% plot( x, y, ':', 'color', [0 0.4 0] );

				% % show a center window for the angles
				% win = 10;
				% fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

				%% time points of several events
				% averaged rf on time
				x = double( mean( [microSacs(index(i,:)).tRf] - [microSacs(index(i,:)).tCue] ) );
				x(2) = x(1);
				y = get(gca,'ylim');
				% plot( x, y, 'k:' );
				% text( x(1), y(2), 'candidates on', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

				% cue on time
				plot( [0 0], y, 'g:' );
				text( 0, y(2), 'cue on', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

				% cue off time
				% plot( [0.2 0.2], y, 'k:' );
				% text( 0.2, y(2), 'cue off', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

				% number of trials
				x = get(gca,'xlim');
				text( x(2), y(2), sprintf( 'nTrials: %d', size(unique([microSacs(index(i,:)).trialIndex]),2) ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );

				% continue;

				%% countour fitting
				tmpAng 	= ang( t > tStart );
				tmpT	= t( t > tStart ) * 1000;
				obj = gmdistribution.fit( [tmpT',tmpAng'], 2, 'Options', statset( 'Display', 'final' ) );
				h = ezcontour( @(x,y) pdf( obj, [x*1000,y] ), [-.22,0.6], [0 360] );

				%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
				%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
				nUp	  = sum( ang < 180 & t > tStart );
				nDown = sum( ang > 180 & t > tStart );
				label = [];
				ratio = 0;
				angRange = 0:180;
				if( strcmp( monkey, 'datou' ) )
					tmpIndex = ang < 180 & t > tStart;
					ratio = nUp / ( nUp + nDown );
					% label = '_{up}';
				elseif( strcmp( monkey, 'abao' ) )
					tmpIndex = ang > 180 & t > tStart;
					ratio = nDown / ( nUp + nDown );
					% label = '_{down}';
					% angRange = -180:0;
					angRange = 180:360;
				end
				
				tmpAng = ang(tmpIndex);
				tmpT = t(tmpIndex);

				% fitting
				p = polyfit( tmpT, tmpAng, 1);
				[r pval] = corrcoef( tmpT, tmpAng );
				plot( [tStart, edges{1}(end)], polyval( p, [tStart, edges{1}(end)] ), 'b', 'LineWidth', 2 );
				text( 0.25, 0-25, [ 'k', label, ' = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.25, 0-50, [ 'r', label, ' = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.7, 0-50, [ 'p', label, ' = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

				% for averaging
				cdata = hist3( [tmpT; tmpAng]', 'edges', { tStart : t_step : edges{1}(end), angRange } )';

				tmpT = tStart : t_step : edges{1}(end);
				tmpAng = ( angRange * cdata ) ./ ( ones(1,181) * cdata );
				tmpT( isnan(tmpAng) ) = [];
				tmpAng( isnan(tmpAng) ) = [];

				% show averaged curve
				plot( tStart : t_step : edges{1}(end), ( angRange * cdata ) ./ ( ones(1,181) * cdata ), 'c', 'LineWidth', 1 );				
				
				% show ratio: proportion of saccades upward for datou (or downward for abao) from tStart
				text( 0.7, 0-25, [ 'ratio', label, ' = ', sprintf('%7.4f',ratio) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

	        end
            % colormap('gray');
            for( i = 1 : size(index,1) )
            	% subplot(2,2,i);
            	% caxis( [ 0, cmax ] );
            end

		end

		function AngleSelection( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.AngleSelection( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1.5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			if( strcmp( monkey, 'abao' ) )
				tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
			else
				return;
			end

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			microSacs = MyMethods.Get1stAfter( microSacs, 'tCue', tStart );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) &...
								   -0.22 < [microSacs.latency] - [microSacs.tCue] & [microSacs.latency] - [microSacs.tCue] < 0.6 );
			cueLocs = [microSacs.cueLoc];
			index = [ cueLocs(1,:) < 0; cueLocs(1,:) > 0 ];
			figure;
			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tCue];
				angs = [microSacs(index(i,:)).angle];
				angs( angs < 0 ) = angs( angs < 0 ) + 360;

				angs( t < tStart ) = [];
				t( t < tStart ) = [];

				subplot(2,2,i);
				plot( t, angs, '.', 'MarkerSize', 0.1 );
				set( gca, 'xlim', [tStart 0.6], 'ylim', [0 360] );

				subplot(2,2,i+2);
				% h = polar( angs/180*pi, t, '.' );
				% set( h, 'MarkerSize', 0.1 );
				xdata = [ t' .* cos( angs'/180*pi ), t' .* sin( angs'/180*pi ) ];
				xdata = [ t'/2, angs' ];
				plot( xdata(:,1), xdata(:,2), '.', 'MarkerSize', 0.1 );
				hold on;
				
				%% svmclassify
				% 1: up
				% 2: down
				% svmStruct = svmtrain( [ xdata( 270 < angs' & angs' < 280, : ); xdata( 100 < angs' & angs' < 110, : ) ],...
				% 	[ repmat( {'2'}, sum( 270 < angs & angs < 280 ), 1 ); repmat( {'1'}, sum( 100 < angs & angs < 110 ), 1 ) ],...
				% 	'showplot', true );
				% group = svmclassify( svmStruct, xdata, 'showplot', true );
				% plot( xdata( cat( 1, group{:} ) == '1', 1 ), xdata( cat( 1, group{:} ) == '1', 2 ), 'r.', 'MarkerSize', 0.1 );
				% plot( xdata( cat( 1, group{:} ) == '2', 1 ), xdata( cat( 1, group{:} ) == '2', 2 ), 'b.', 'MarkerSize', 0.1 );
				% axis('equal');
				% x = get( gca, 'xlim' );
				% y = get( gca, 'ylim' );
				% text( x(2), y(2), sprintf( '%f', sum( cat( 1, group{:} ) == '1' )/length(xdata) ), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right' );

				%% kmeans
				idx = kmeans( xdata, 2 );
				plot( xdata( idx == 1, 1 ), xdata( idx == 1, 2 ), 'r.', 'MarkerSize', 0.1 );
				plot( xdata( idx == 2, 1 ), xdata( idx == 2, 2 ), 'b.', 'MarkerSize', 0.1 );
				% axis('equal');
				x = get( gca, 'xlim' );
				y = get( gca, 'ylim' );
				text( x(2), y(2), sprintf( '%f', sum(idx==1)/length(idx) ), 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right' );

			end
		end

		function RTData = RankSumTest( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.RankSumTest( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end		

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			% tStart = -.25;
			if( strcmp( monkey, 'abao' ) )
				tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
				% tStart = 0;
			else
				return;
			end
			% tStart = 0;

			index = find( [microSacs.latency] - [microSacs.tCue] > tStart );
					
			trialIndex = [microSacs(index).trialIndex];
			index = index( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );
			microSacs(index) = [];
			% microSacs = microSacs( ( strfind( [microSacs.name], '201212' ) + 5 ) / 6 );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tCue] < 0.6 );

			tarLoc = [microSacs.tarLoc];
			cueLoc = [microSacs.cueLoc];
			index = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0 ] & repmat( tarLoc(2,:) == 0, 2, 1 );
			index = [ index; [ cueLoc(1,:) < 0; cueLoc(1,:) > 0 ] & repmat( tarLoc(2,:) ~= 0, 2, 1 ) ];
			index = [...
						cueLoc(1,:) < 0 & tarLoc(2,:) == 0;...
						cueLoc(1,:) < 0 & tarLoc(2,:) ~= 0;...
						cueLoc(1,:) > 0 & tarLoc(2,:) == 0;...
						cueLoc(1,:) > 0 & tarLoc(2,:) ~= 0; ];
            names = { 'left', 'oblique left', 'right', 'oblique right' };

			for( i = 24 : -1 : 1 )
				index( i, : ) = cueLoc(1,:) == cueLocs(1,i) & cueLoc(2,:) == cueLocs(2,i) & tarLoc(2,:) == 0;
			end			
            names = eval( [ '{' sprintf( '''%4d%4d'',', cueLocs ) '}' ] );

			RTData.bin = 0.05;
			RTData.tStart = tStart-0;
			RTData.tEnd = 0.6;
			% nPoints = floor( ( RTData.tEnd - RTData.tStart )*1000 / ( RTData.bin*1000 ) );
			nPoints = round( ( RTData.tEnd - RTData.tStart ) * 1000 + 1 );
			%RTData.rankTestIndex =  false( size(index,1), size(microSacs,2), nPoints ) ;
			RTData.data = cell( size(index,1), nPoints );

			%% collect data
            t = [microSacs.latency] - [microSacs.tCue];
            angles = [microSacs.angle];
            sum( angles>0 & t<0 ) / sum(t<0)
			for( i = 1 : size(index,1) )
				for( j = 1 : nPoints )
					% rankTestIndex = index(i,:) & RTData.tStart + RTData.bin*(j-1) <= t & t < RTData.tStart + RTData.bin*j;
					if( j <= RTData.bin*1000/2 )
						rankTestIndex = index(i,:) & RTData.tStart <= t & t < RTData.tStart + (j-1)/1000 + RTData.bin/2;
					elseif( j > nPoints - RTData.bin*1000/2 )
						rankTestIndex = index(i,:) & RTData.tStart + (j-1)/1000 - RTData.bin/2 <= t & t < RTData.tEnd;
					else
						rankTestIndex = index(i,:) & RTData.tStart + (j-1)/1000 - RTData.bin/2 <= t & t < RTData.tStart + (j-1)/1000 + RTData.bin/2;
					end
					if( strcmp( monkey, 'abao' ) )
						rankTestIndex = rankTestIndex & ( angles < 0 & t > 0 | t < 0 );
					elseif( strcmp( monkey, 'datou' ) )
						rankTestIndex = rankTestIndex & angles > 0;
					end
					RTData.data{i,j} = angles((rankTestIndex));
					if( isempty( RTData.data{i,j} ) ) RTData.data{i,j} = single(NaN); end
				end
			end

			%% difference test using RankSum Test
            figure; hold on;
            pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
            set( gcf, 'NumberTitle', 'off', 'name', 'diff_test' );
            nLines = size(RTData.data,1);
            nPoints = size(RTData.data,2);
            EX = cellfun( @(c) nanmean(c), RTData.data );
            for( i = size(EX,1) : -1 : 1 )
            	SPEED(i,:) = conv( gradient( EX(i,:), 0.001 ), ones(1,11)/11, 'same' );
            end
            if( strcmp( monkey, 'abao' ) )	% base line for abao: population vector
            	ind = 1 : round( ( 0 - RTData.tStart ) / RTData.bin )
            	% EX(:,ind) = cellfun( @(c) cart2pol( cos((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)', sin((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)' )/pi*180, RTData.data(:,ind) );
            end
            STD = cellfun( @(c) nanstd(c), RTData.data );
            SEM = cellfun( @(c) nanstd(c) / sqrt(size(c,2)), RTData.data );
            % x = RTData.tStart + RTData.bin/2 : RTData.bin : RTData.tEnd - RTData.bin/2;
            % x = RTData.tStart + RTData.bin/2 : 0.001 : RTData.tStart + RTData.bin/2 + ( nPoints - 1 ) * 0.001;
            x = RTData.tStart : 0.001 : RTData.tEnd;
            for( i = 1 : size(EX,1) )
            	if( i <= 12 )	colour = [ (i-1) / (size(index,1)+1), (i-1) / (size(index,1)+1), 1 ];
            	else 			colour = [ 1, (i-13) / (size(index,1)+1), (i-13) / (size(index,1)+1) ];	end
            	% if( i <= 4 )		colour = [ 1, (i-1) / 6 , (i-1) / 6  ];
            	% elseif( i <= 8 )	colour = [ (i-5) / 6 , 1, (i-5) / 6  ];
            	% elseif( i <= 12 )	colour = [ (i-9) / 6 , (i-9) / 6 , 1 ];
            	% elseif( i <= 16 )	colour = [ 1, 1, (i-13) / 6  ];
            	% elseif( i <= 20 )	colour = [ (i-17) / 6 , 1, 1 ];
            	% else				colour = [ 1, (i-21) / 6 , 1 ];	end
            	% if( i <= 2 )	colour = [ 1, (i-1) / 3, (i-1) / 3 ];
            	% else 			colour = [ (i-3) / 3, (i-3) / 3, 1 ]; end
            	ToolKit.ErrorFill( x, EX(i,:), SEM(i,:), [0 0 0], 'LineStyle', 'none', 'FaceColor', min( [ colour; 1,1,1 ] ));%, 'FaceAlpha', 0.8 );
            	h(i) = plot( x, EX(i,:), 'LineWidth', 2, 'color', colour, 'DisplayName', names{i} );
            	% plot( x, SPEED(i,:), 'LineWidth', 2, 'color', colour );
            	% h(i) = errorbar( x, EX(i,:), SEM(i,:), SEM(i,:), 'color', colour, 'LineWidth', 2, 'marker', '.', 'DisplayName', names{i} );

            	% p{i} = ones(nPoints-1,nPoints);
            	% for( m = 1 : nPoints-1 )
            	% 	for( n = m+1 : nPoints )
            	% 		% p{i}(m,n) = ranksum( double(RTData.data{i,m}), double(RTData.data{i,n}), 'tail', 'both', 'method', 'approximate' );
            	% 		%[ ~, p{i}(m,n) ] = ttest2( double(RTData.data{i,m}), double(RTData.data{i,n}), [], [], 'unequal' );
            	% 		% p{i}(n,m) = p{i}(m,n);
            	% 	end
            	% end

            	continue;
            	% fitting            	
            	if( strcmp( monkey, 'abao' ) )
					tmpAng = angles( index(i,:) & angles < 0 & t > RTData.tStart );
					tmpT = t( index(i,:) & angles < 0 & t > RTData.tStart );
				elseif( strcmp( monkey, 'datou' ) )
					tmpAng = angles( index(i,:) & angles > 0 & t > RTData.tStart );
					tmpT = t( index(i,:) & angles > 0 & t > RTData.tStart );
				end            	
				p = polyfit( tmpT, tmpAng, 1)
				[r pval] = corrcoef( tmpT, tmpAng )
				plot( [tStart, RTData.tEnd], polyval( p, [tStart, RTData.tEnd] ), 'color', colour, 'LineWidth', 2 );
				text( 0.25, 0-25, [ 'k = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.25, 0-50, [ 'r = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.7, 0-50, [ 'p = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );	
            end
            plot( [0 0], get(gca,'ylim'), 'k:' );
            legend( h, 'location', 'NorthEastOutside', 'FontSize', 40 );
            set( gca, 'xtick', 0.1:0.1:0.6, 'xlim', [0.09 0.62] );
            xlabel( 'Time from cue on (s)', 'FontSize', 12 );
            ylabel( 'Averaged microsaccades direction with SEM (\circ)', 'FontSize', 12 );
            return;
 			
 			ang_step = 10;
            if( strcmp( monkey, 'abao' ) )
            	edges = -180 : ang_step : 0;
            elseif( strcmp( monkey, 'datou' ) )
            	edges = 0 : ang_step : 180;
            end

            y = get(gca,'ylim');
            set( gca, 'xlim', [ RTData.tStart, RTData.tEnd ], 'xtick', x, 'ylim', [y(1) y(2)+10] );
            y = get(gca,'ylim');
            for( i = 1 : 2 )
            	text( RTData.tStart + 0.015 + (i-1)*0.15, y(2)-0.02*(y(2)-y(1)), names{i}, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
            	text( RTData.tStart + 0.025 + (i-1)*0.15, y(2)-0.02*(y(2)-y(1)), ToolKit.Array2Text(p{i}), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
            end

            for( i = [1,3] )
	            p{end+1} = ones(1,nPoints)*-1;
	            for( j = 1 : nPoints )
	            	p{end}(j) = ranksum( double(RTData.data{i,j}), double(RTData.data{i+1,j}), 'tail', 'both', 'method', 'approximate' );
	            	%[ ~, p{end}(j) ] = ttest2( double(RTData.data{i,j}), double(RTData.data{i+1,j}), [], [], 'unequal' );
	            end
	            text( RTData.tStart + 0.015, y(2) - ( 0.20+(i-1)*0.025 )*( y(2)-y(1) ), [ names{i} ' vs ' names{i+1} ToolKit.Array2Text(p{end}) ], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
	        end
	        return;

            RTData.EX = EX;
            RTData.STD = STD;
            RTData.p = p;            

            figure;
            for( i = 1 : nLines )
            	for( j = 1 : nPoints )
            		subplot( nLines, nPoints, (i-1)*nPoints + j );
            		[data,ax] = hist( RTData.data{i,j}, edges );
            		set( bar( ax, data/sum(data) ), 'EdgeColor', 'none', 'FaceColor', [ i / (nPoints+1), 1, i / (nPoints+1) ] );
            	end
            end

            data = cellfun( @(c) hist( c, edges ), RTData.data, 'UniformOutput', 0 );
            % data = cellfun( @(c) c/sum(c), data, 'UniformOutput', 0 );
            for( i = 1 : nLines )
            	set( figure, 'NumberTitle', 'off', 'name', names{i} );
            	bar( edges, cat( 1, data{i,:} )' );
            	title( names{i} );
            end

            for( i = [1,3] )
	            for( j = 1 : nPoints )
	            	set( figure, 'NumberTitle', 'off', 'name', [ names{i}, '&', names{i+1}, num2str(j) ] );
	            	bar( edges, cat( 1, data{i:i+1,j} )' );
	            	title( [ names{i}, '&', names{i+1}, num2str(j) ] );
	            end
	        end
		end

		function [ stats, pVal ] = SlopeTest( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.SlopeTest( folder, monkey, ampEdges = [0,5], isOblique = false )' ); return; end
			if( nargin() < 3 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			% tStart = -.25;
			if( strcmp( monkey, 'abao' ) )
				tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
				% tStart = 0;
			else
				return;
			end
			% tStart = 0;

			index = find( [microSacs.latency] - [microSacs.tCue] > tStart );
					
			trialIndex = [microSacs(index).trialIndex];
			index = index( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );
			microSacs(index) = [];
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tCue] < 0.6 );

			%% correlation with target location
			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			% mss{2} = microSacs( tarLoc(2,:) ~= 0 );
			% mss{1} = microSacs( tarLoc(2,:) == 0 );

			%% correlation with response saccade latency
			latency = [microSacs.responseLat];
			% mss{2} = microSacs( latency < 0.05 );
			% mss{1} = microSacs( latency > 0.13 );

			%% correlation with response saccade endpoint
			respLoc = [microSacs.responseLoc];
			meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% mss{1} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );

			%% correlation with response saccade amplitude
			amplitude = [microSacs.responseAmp];
			% amplitude = [microSacs.responseDur];
			% meanL = mean( amplitude( respLoc(1,:) < 0 ) );
			% meanR = mean( amplitude( respLoc(1,:) > 0 ) );
			meanL = median( amplitude( respLoc(1,:) < 0 ) )
			meanR = median( amplitude( respLoc(1,:) > 0 ) )
			% figure;hist( amplitude, 5:0.5:15 ); return;
			% mss{2} = microSacs( respLoc(1,:) < 0 & amplitude < meanL | respLoc(1,:) > 0 & amplitude < meanR );
			% mss{1} = microSacs( respLoc(1,:) < 0 & amplitude > meanL | respLoc(1,:) > 0 & amplitude > meanR );
			sortedAmp = { sort( amplitude( respLoc(1,:) < 0 ) ), sort( amplitude( respLoc(1,:) > 0 ) ) };
			figure;			
			for( i = 2 : -1 : 1 )
				subplot( 1, 2, i );
				hist( sortedAmp{i}, 5:0.2:15 );
				set( gca, 'xlim', [4 16] );
				MEAN = mean( sortedAmp{i} );
				STD = std( sortedAmp{i} );
				sortedAmp{i} = sortedAmp{i}( MEAN - 2*STD <= sortedAmp{i} & sortedAmp{i} <= MEAN + 2*STD );
				st = floor( size( sortedAmp{i}, 2 ) / 8 );
				bounds{i}.start = sortedAmp{i}( 1 : 30 : end-st );
				bounds{i}.end = sortedAmp{i}( st : 30 : end );
			end
			bounds = { sortedAmp{1}( 1 : floor( size(sortedAmp{1},2)/8 ) : end ), sortedAmp{2}( 1 : floor( size(sortedAmp{2},2)/8 ) : end ) };
			bounds{1}(1) = bounds{1}(1) - 0.001;
			bounds{2}(1) = bounds{2}(1) - 0.001;
			for( i = size(bounds{1},2)-1 : -1 : 1 )
				mss{i} = microSacs( respLoc(1,:) < 0 & bounds{1}(i) <= amplitude & amplitude <= bounds{1}(i+1) |...
									respLoc(1,:) > 0 & bounds{2}(i) <= amplitude & amplitude <= bounds{2}(i+1) );
			end

			%% correlation with response saccade endpoint accuracy
			respLoc = [microSacs.responseLoc];
			centerLX = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			centerLY = mean( respLoc( 2, respLoc(1,:) < 0 ) );
			centerRX = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			centerRY = mean( respLoc( 2, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) < 0.6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) < 0.6 );
			% mss{1} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) > .6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) > .6 );

			%% correlation with response saccade duration



			nGroups = [ 8 8 ];
			nGroups = ones(1,size(bounds{1},2)-1);
			for( m = size(mss,2) : -1 : 1 )
				nSacs = floor( size(mss{m},2)/nGroups(m) );	% step between two adjacent groups
				for( k = nGroups(m):-1:1 )
					tmp_mss = mss{m}( ( (k-1)*nSacs + 1 ) : k*nSacs );
					cueLoc = [tmp_mss.cueLoc];
					index = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0 ];
					angles = [tmp_mss.angle];
					t = [tmp_mss.latency] - [tmp_mss.tCue];
					for( i = 2:-1:1 )
						% fitting
		            	if( strcmp( monkey, 'abao' ) )
							tmpAng = angles( index(i,:) & angles < 0 & t > tStart );
							tmpT = t( index(i,:) & angles < 0 & t > tStart );
							angRange = -180:0;
						elseif( strcmp( monkey, 'datou' ) )
							tmpAng = angles( index(i,:) & angles > 0 & t > tStart );
							tmpT = t( index(i,:) & angles > 0 & t > tStart );
							angRange = 0:180;
						end

						% % for averaging
						% t_step = 0.01;
						% ang_step = 2;
						% edges = { -0.22 : t_step : 0.6, -180 : ang_step : 180 };
						% cdata = hist3( [tmpT; tmpAng]', 'edges', { tStart : t_step : edges{1}(end), angRange } )';

						% % tmpT = tStart : t_step : edges{1}(end);
						% % tmpAng = ( angRange * cdata ) ./ ( ones(1,181) * cdata );
						% % tmpT( isnan(tmpAng) ) = [];
						% % tmpAng( isnan(tmpAng) ) = [];

						coefs = polyfit( tmpT, tmpAng, 1);
						stats(m,k,i).coefs = coefs(1);
						[ r, pval ] = corrcoef( tmpT, tmpAng );
						stats(m,k,i).r = r(2);
						stats(m,k,i).pval = pval(2);
					end
				end
			end

			figure; hold on;
			colors = {'r','b'};
			for( i = 1 : 2 )
				plot( ( bounds{i}(1:end-1) + bounds{i}(2:end) ) / 2, ([ stats(:,1,i).coefs ]), '*-', 'color', colors{i} );
			end
			return;


			data{4} = [stats(2,:,2).coefs];	% oblique right
			data{1} = [stats(1,:,1).coefs];	% horizontal left
			data{2} = [stats(2,:,1).coefs];	% oblique left
			data{3} = [stats(1,:,2).coefs];	% horizontal right

			for( i = size(data,2) : -1 : 1 )
				EX(i) = mean(data{i});
				SEM(i)	 = std(data{i}) / sqrt(size(data{i},2));
			end

			pVal.L_OL	= ToolKit.PermutationTest( data{1}, data{2} );
			pVal.R_OR	= ToolKit.PermutationTest( data{3}, data{4} );
			pVal.L_R	= ToolKit.PermutationTest( data{1}, data{3} );
			pVal.OL_OR	= ToolKit.PermutationTest( data{2}, data{4} );

			colors = { 'r', [1,1/3,1/3], 'b', [1/3,1/3,1] };

			FONTSIZE = 24;
			figure;
			subplot(1,2,1); hold on;
			for( i = 1 : size(data,2) )
				if( isempty(data{i}) ) continue; end
				bar( ( sum( nGroups( mod( 0:i-2, 2 ) + 1 ) ) + 1 : sum( nGroups( mod( 0:i-1, 2 ) + 1 ) ) ) + 2*(i-1), data{i}, 0.8, 'EdgeColor', 'none', 'FaceColor', colors{i} );
			end

			% return;

			subplot(1,2,2); hold on;
			for( i = 1 : 4 )
				bar( i, mean(data{i}), 0.8, 'EdgeColor', 'none', 'FaceColor', colors{i} );
				plot( [ i, i ], EX(i) + [ -SEM(i), SEM(i) ] / 2, 'LineWidth', 2, 'color', 'k' );% 'r' );
			end
			
			% show significance
			index = { [1 2], [3 4], [1 3 2], [2 4 3] };
			pVals = [ pVal.L_OL, pVal.R_OR, pVal.L_R, pVal.OL_OR ];
			hDist = [ 0.05, 0.05, 0.1, 0.15 ];
			for( i = 1 : 4 )
				for( k = size( index{i}, 2 ) : -1 : 1 )
					if( EX( index{i}(k) ) < 0 )
						y(k) = EX( index{i}(k) ) - SEM( index{i}(k) ) / 2;
					else
						y(k) = EX( index{i}(k) ) + SEM( index{i}(k) ) / 2;
					end
				end
				if( size( index{i} , 2 ) > 2 )
					if( all( y < 0 ) )
						y(1) = min(y);
					else
						y(1) = max(y);
					end
				end
				ToolKit.ShowSignificance( [ index{i}(1), y(1) ], [ index{i}(2), y(2) ], pVals(i), hDist(i), true, 'FontSize', FONTSIZE );
			end

			set( gca, 'xlim', [0 5], 'xtick', 1:4, 'xTickLabel', { 'L', 'OL', 'R', 'OR' }, 'FontSize', FONTSIZE );
			% y = get( gca, 'ylim' );
			% text( 1.5, y(2), sprintf( '%.4f', pVal.L_OL ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			% text( 3.5, y(2), sprintf( '%.4f', pVal.R_OR ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			ylabel( 'Microsaccades direction rotation speed (\circ/s)', 'FontSize', FONTSIZE );

		end

		function OtherCorr( folder, monkey, parameter, ampEdges )
			if( nargin() < 3 ), disp( 'Usage: MyMethods.SlopeTest( folder, monkey, parameter, ampEdges = [0,5], isOblique = false )' ); return; end
			if( nargin() < 4 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			field = 'tCue';
			% field = 'tRf';
			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			tStart = MyMethods.GetTStart( monkey, 'asc' );
			microSacs = MyMethods.Get1stAfter( microSacs, field, tStart );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) &...
								   tStart < [microSacs.latency] - [microSacs.(field)] & [microSacs.latency] - [microSacs.(field)] < 0.6 );


			respLoc = [microSacs.responseLoc];
			switch(lower(parameter))		% which parameter to test
				case 'amplitude'	% response saccade amplitude
					tarData = [microSacs.responseAmp];
					edges = 5 : 0.2 : 15;
					XLIM = [4 16];
				case 'duration'		% response saccade duration
					tarData = [microSacs.responseDur];
					edges = 0.05 : 0.001 : 0.15;
					XLIM = [0.05 0.15];
				case 'latency'		% response saccade latency
					tarData = [microSacs.responseLat];
					edges = -.15 : .01 : .3;
					XLIM = [-.16 .31];
				case 'accuracy'		% response saccade accuracy
					centerLX = mean( respLoc( 1, respLoc(1,:) < 0 ) );
					centerLY = mean( respLoc( 2, respLoc(1,:) < 0 ) );
					centerRX = mean( respLoc( 1, respLoc(1,:) > 0 ) );
					centerRY = mean( respLoc( 2, respLoc(1,:) > 0 ) );
					tarData = zeros( size(microSacs) );
					tarData( respLoc(1,:) < 0 ) = sqrt( ( respLoc( 1, respLoc(1,:) < 0 ) - centerLX ).^2 + ( respLoc( 2, respLoc(1,:) < 0 ) - centerLY ).^2 );
					tarData( respLoc(1,:) > 0 ) = sqrt( ( respLoc( 1, respLoc(1,:) > 0 ) - centerRX ).^2 + ( respLoc( 2, respLoc(1,:) > 0 ) - centerRY ).^2 );
					edges = 0 : .1 : 5;
					XLIM = [-0.1 5.1];
				otherwise
					return;
			end
			%% correlation with target location
			% tarLoc = [microSacs.tarLoc];
			% microSacs = microSacs( tarLoc(2,:) == 0 );
			% mss{2} = microSacs( tarLoc(2,:) ~= 0 );
			% mss{1} = microSacs( tarLoc(2,:) == 0 );


			%% correlation with response saccade endpoint
			% respLoc = [microSacs.responseLoc];
			% meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			% meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% mss{1} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );


			sortedTarData = { sort( tarData( respLoc(1,:) < 0 ) ), sort( tarData( respLoc(1,:) > 0 ) ) };
			set( figure, 'NumberTitle', 'off', 'name', [ monkey, '_Response', parameter ] );
			for( i = 2 : -1 : 1 )
				subplot( 1, 2, i );
				hist( sortedTarData{i}, edges );
				set( gca, 'xlim', XLIM );
				MEAN = mean( sortedTarData{i} );
				STD = std( sortedTarData{i} );
				sortedTarData{i} = sortedTarData{i}( MEAN - 2*STD <= sortedTarData{i} & sortedTarData{i} <= MEAN + 2*STD );
				st = floor( size( sortedTarData{i}, 2 ) / 8 );
				bounds{i}.start = sortedTarData{i}( 1 : 10 : end-st );
				bounds{i}.end = sortedTarData{i}( st+1 : 10 : end );
			end
			index = [ respLoc(1,:) < 0; respLoc(1,:) > 0 ];
			for( i = 2 : -1 : 1 )
				for( k = size(bounds{i}.start,2) : -1 : 1 )
					mss{i}{k} = microSacs( index(i,:) & bounds{i}.start(k) <= tarData & tarData <= bounds{i}.end(k) );
				end
			end

			%% correlation with response saccade endpoint accuracy
			
			% mss{2} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) < 0.6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) < 0.6 );
			% mss{1} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) > .6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) > .6 );



			for( i = 2 : -1 : 1 )
				for( k = size(mss{i},2) : -1 : 1 )
					angles = [mss{i}{k}.angle];
					t = [mss{i}{k}.latency] - [mss{i}{k}.(field)];
					
					% fitting
	            	if( strcmp( monkey, 'abao' ) )
						tmpAng = angles( angles < 0 );
						tmpT = t( angles < 0 );
						angRange = -180:0;
					elseif( strcmp( monkey, 'datou' ) )
						tmpAng = angles( angles > 0 );
						tmpT = t( angles > 0 );
						angRange = 0:180;
					end

					coefs = polyfit( tmpT, tmpAng, 1);
					stats{i}(k).coefs = coefs(1);
					[ r, pval ] = corrcoef( tmpT, tmpAng );
					stats{i}(k).r = r(2);
					stats{i}(k).pval = pval(2);
				end
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, '_Slope.VS.Response', parameter ] ); hold on;
			colors = {'r','b'};
			for( i = 1 : 2 )
				plot( ( bounds{i}.start + bounds{i}.end ) / 2, abs([ stats{i}.coefs ]), '.-', 'color', colors{i} );
			end
			return;
		end

		function DifTime( monkey, task, tWin )
			if( nargin() < 2 )
				disp( 'Usage: MyMethods.DifTime( monkey, task )' );
				disp( '    task: SC for spatial cue task; CC for color cue task' );
				return;
			end
			if( nargin() <= 2 ) tWin = 0.05; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				fprintf( '%sMicroSacs not found!', monkey );
				return;
			end

			if( strcmpi( task, 'sc' ) )
				t = [microSacs.latency] - [microSacs.tCue];
			elseif( strcmpi( task, 'cc' ) )
				t = [microSacs.latency] - [microSacs.tRf];
			else
				disp( 'Usage: MyMethods.DifTime( monkey, task )' );
				disp( '    task: SC for spatial cue task; CC for color cue task' );
				return;
			end
			angs = [microSacs.angle];
			tarLoc = [microSacs.tarLoc];

			tStep = 0.001;
			n = ceil( ( max(t) - min(t) - tWin ) / tStep ) + 1;
			for( i = max(t) - tWin : -tStep : min(t) )
				iT = i <= t & t < i + tWin;
				iHori = tarLoc(2,:) == 0;
				iObliq = ~iHori;
				iLeft = tarLoc(1,:) < 0;
				iRight = tarLoc(1,:) > 0;

				% horizontal target
				left = angs( iHori & iLeft & iT & angs > 0 );
				right = angs( iHori & iRight & iT & angs > 0 ) - 10;
				if( ~isempty(left) & ~isempty(right) )
					hori(n) = ranksum( left, right, 'tail', 'both', 'method', 'approximate' );
				else
					hori(n) = NaN;
				end

				% oblique target
				left = angs( iObliq & iLeft & iT & angs > 0 );
				right = angs( iObliq & iRight & iT & angs > 0 );
				if( ~isempty(left) & ~isempty(right) )
					obliq(n) = ranksum( left, right, 'tail', 'both', 'method', 'approximate' );
				else
					obliq(n) = NaN;
				end

				n = n - 1;
			end
			hori(1:n) = [];
			obliq(1:n) = [];

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, '_DifTime_tWin', num2str(tWin), '_', task ] );
			hold on;
			plot( ( min(t) : tStep : max(t) - tWin ) + tWin/2, hori, 'b' );
			plot( ( min(t) : tStep : max(t) - tWin ) + tWin/2, obliq, 'r' );
			plot( [ min(t), max(t) ], [0.05 0.05], 'k:' );
			set( gca, 'ylim', [-1 2] );

			xlabel( 'Center of window (s)', 'FontSize', 12 );
			ylabel( 'P value of rank sum test', 'FontSize', 12 );
			title( sprintf( 'Differentiation time (time window: %.2fs)', tWin ), 'FontSize', 12 );

		end

		function AbaoUpSacs()
			global abaoMicroSacs;
			if( isempty(abaoMicroSacs) )
				abaoMicroSacs = MyMethods.LoadMicroSacs( 'D:\data\cue_task_refinedmat\abao\cue\PopulationData\rawdata' );
			end
            microSacs = abaoMicroSacs;
            tStart = 0.075;

			%microSacs = microSacs( [microSacs.amplitude] < 1 & [microSacs.latency] - [microSacs.tCue] > tStart );
			indexUpSacs = [microSacs.angle] > 0 & [microSacs.amplitude] < 1 & [microSacs.latency] - [microSacs.tCue] > tStart;
			upSacs = microSacs(indexUpSacs);
			beforeUpSacs = microSacs( [ indexUpSacs(2:end), logical(0) ] );

			global sacLocation;
			if( isempty(sacLocation) )
				sacLocation(size(upSacs,2)).session = [];
				sacLocation(1).iTrial = [];
				sessions = mat2cell( cat(1,upSacs.name), ones(size(upSacs)), 6 );
				[sacLocation.session] = sessions{:};
				iTrials = num2cell( [upSacs.trialIndex] );
				[sacLocation.iTrial] = iTrials{:};
			end

			figure; hold on;
			colors = { 'r', 'b' };
			termiPoints = { [upSacs.termiPoints], [beforeUpSacs.termiPoints] };
			data = zeros( 2, size( termiPoints{1}, 2 ) / 2 * 3 );
			for( k = 1 : 2 )
				data( :, 1:3:end ) = termiPoints{k}( :, 1:2:end );
				data( :, 2:3:end ) = termiPoints{k}( :, 2:2:end );
				data( :, 3:3:end ) = NaN;
				% plot( data(1,:), data(2,:), 'color', colors{k} );
				% plot( data(1,1:3:end), data(2,1:3:end), '.', 'color', colors{k} );
				% plot( data(1,2:3:end), data(2,2:3:end), '*', 'color', colors{k} );
			end
			data( :, 1:3:end ) = termiPoints{2}( :, 2:2:end );
			data( :, 2:3:end ) = termiPoints{1}( :, 1:2:end );
			data( :, 3:3:end ) = NaN;
			plot( data(1,:), data(2,:), 'g' );

			figure;
			set( gcf, 'NumberTitle', 'off', 'name', 'amplitude' );
			subplot(1,3,1);
			hist( [beforeUpSacs.amplitude], 0:0.1:5 );
			subplot(1,3,2);
			hist( [upSacs.amplitude], 0:0.1:5 );
			subplot(1,3,3);
			hist( sqrt( (termiPoints{1}(1,1:2:end) - termiPoints{2}(1,2:2:end)).^2 + (termiPoints{1}(2,1:2:end) - termiPoints{2}(2,2:2:end)).^2 ), 0:0.1:5 );
			title('amplitude');

			figure; hold on;
			set( gcf, 'NumberTitle', 'off', 'name', 'latency' );
			t = [ [beforeUpSacs.latency] - [beforeUpSacs.tCue]; [upSacs.latency] - [upSacs.tCue]; [upSacs.latency] - [upSacs.tCue] - ( [beforeUpSacs.latency] - [beforeUpSacs.tCue] ) ];
			tStep = 0.01;
			for( k = 1 : 3 )
				subplot(1,3,k);
				edges = min(t(k,:)) - tStep/2 : tStep : max(t(k,:)) + tStep/2;
				hist( t(k,:), edges );
			end
			title('latency');

			figure; hold on;
			set( gcf, 'NumberTitle', 'off', 'name', 'latency' );
			plot( 1:size(t,2), t(1,:), 'b' );
			plot( 1:size(t,2), t(2,:), 'r' );
			set(gca,'ylim',[-2,4],'xlim',[1,100]);
			title('latency');

			figure;
			set( gcf, 'NumberTitle', 'off', 'name', 'angle' );
			angs = [ [beforeUpSacs.angle]; [upSacs.angle]; [upSacs.angle] - [beforeUpSacs.angle] ];
			angStep = 5;
			for( k = 1 : 3 ) 
				subplot(2,2,k);
				edges = min(angs(k,:)) - angStep/2 : angStep : max(angs(k,:)) + angStep/2;
				hist( angs(k,:), edges );
			end
			subplot(2,2,3);
			angs( 1, angs(1,:) < 0 ) = angs( 1, angs(1,:) < 0 ) + 360;
			plot( angs(1,:), angs(2,:), '.' );

			subplot(2,2,4); hold on;
			plot( 1:size(angs,2), angs(1,:), 'b' );
			plot( 1:size(angs,2), angs(2,:), 'r' );
			set( gca, 'xlim', [1,100] );
			title('angle');

			figure;
			set( gcf, 'NumberTitle', 'off', 'name', 'trialIndex' );
			hist( double( [upSacs.trialIndex] - [beforeUpSacs.trialIndex] ) );
			title('trialIndex');

			figure;
			plot( t(3,:), [beforeUpSacs.amplitude], '*' );
			figure;
			plot( t(3,:), [beforeUpSacs.angle], '*' );

		end

		function ExtractUpTrials()
			upTrials = [];
			folder = 'D:\data\cue_task_refinedmat\abao\cue\PopulationData\rawdata';
			folders1 = ToolKit.ListFolders(folder);
			for( i = 1 : size(folders1,1) )
				folders2 = ToolKit.ListFolders( ToolKit.RMEndSpaces( folders1(i,:) ) );
				for( j = 1 : size(folders2,1) )
					sc = SCueBlocksAnalyzer( ToolKit.ListMatFiles( ToolKit.RMEndSpaces( folders2(j,:) ) ), 1+8+16 );
					for( iBlock = 1 : sc.nBlocks )
						trials = sc.blocks(iBlock).trials( [sc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT & [ 1, [sc.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
						index = false( 1, size(trials,2) );
						for( iTrial = 1 : size(trials,2) )
							sacs = trials(iTrial).saccades( 1 : trials(iTrial).iResponse1 - 1 );
							if( ~isempty(sacs) && any( [sacs.latency] - trials(iTrial).cue.tOn > tStart & [sacs.angle] > 0 & [sacs.amplitude] < 1 ) )
								index(iTrial) = true;
							end
						end
						upTrials = [ upTrials, trials(index) ];
					end
				end
			end
			save( 'D:\data\cue_task_refinedmat\abao\cue\PopulationData\upTrials.mat', 'upTrials' );
		end

		function AnaUpTrials( hFig, evnt )
			global upTrials;
			if( isempty(upTrials) )
				load('D:\data\cue_task_refinedmat\abao\cue\PopulationData\upTrials.mat');
			end

			if( nargin() == 0 )
				figure( 'NumberTitle', 'off', 'name', 'trial: 1', 'KeyPressFcn', @MyMethods.AnaUpTrials );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
				jf.setMaximized(1);
				upTrials(1).PlotEyeTrace(0);
				return;
			end

			iTrial = sscanf( get( hFig, 'name' ), '%s%d' );
			switch evnt.Key
				case 'leftarrow'					
					iTrial = iTrial(end) - 1;
				case 'downarrow'
					iTrial = iTrial(end) - 100;
				case { 'hyphen', 'subtract' }
					iTrial = iTrial(end) - 1000;
				case 'rightarrow'
					iTrial = iTrial(end) + 1;
				case 'uparrow'
					iTrial = iTrial(end) + 100;
				case { 'equal', 'add' }
					iTrial = iTrial(end) + 1000;
				case 'return'
					iTrial = sscanf( input('iTrial: ','s'), '%d' );
				otherwise
					return;
			end
			if( iTrial < 1 ) iTrial = 1; end
			if( iTrial > size(upTrials,2) ) iTrial = size(upTrials,2); end

			cla;
			upTrials(iTrial).PlotEyeTrace(0);
			set( hFig, 'name', [ 'trial: ', num2str(iTrial) ] );

		end

		function FirstVSSecond( folder, monkey, task )
			if( nargin() < 3 ), disp( 'Usage: MyMethods.FirstVSSecond( folder, monkey )' ); return; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			if( strcmpi( monkey, 'abao' ) )
            	if( strcmpi( task, 'asc' ) )
            		tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
            	elseif( strcmpi( task, 'cc' ) )
					tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.103 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.106 smoothed with a Gaussian)
				end
			elseif( strcmpi( monkey, 'datou' ) )
				if( strcmpi( task, 'asc' ) )
					tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
				elseif( strcmpi( task, 'cc' ) )
					tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.128 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.124 smoothed with a Gaussian)
				end
			else
				return;
			end

			if( strcmpi( task, 'asc' ) )
				microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );
			elseif( strcmpi( task, 'cc' ) || strcmpi( task, 'mem' ) )
            	microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > tStart );
            end

			iFirst = find( [ microSacs(1:end-1).trialIndex ] == [ microSacs(2:end).trialIndex ] );
			FirstAngs = [microSacs(iFirst).angle];
			SecondAngs = [microSacs(iFirst+1).angle];
			SecondAngs( SecondAngs < 0 ) = SecondAngs( SecondAngs < 0 ) + 360;
			figure; hold on;
			colormap('hot');
			cmp = colormap;

			% plot( FirstAngs, SecondAngs, 'b*' );
			ang_step = 5;
			% [data, ax] = hist3( [FirstAngs; SecondAngs]', 'edges', { -180:ang_step:180, 0:ang_step:360 } );
			% pcolor( ax{1}, ax{2}, data' );

			cdata = hist3( [FirstAngs; SecondAngs]', 'edges', { -180:ang_step:180, 0:ang_step:360 } )';
			nColors = size(cmp,1) - 1;
	        colour = reshape( cmp( round( cdata * nColors / max(max(cdata)) ) + 1 , : ), [ size(cdata), 3 ] );
			image( -180:ang_step:180, 0:ang_step:360, colour );

			plot( [-180 180], [0 360], 'w--', 'LineWidth', 1 );
			plot( [-180 180], [360 0], 'w--', 'LineWidth', 1 );
			axis equal;
			set(gca, 'color', 'k', 'XColor', 'w', 'YColor', 'w', 'xlim',[-180 180], 'ylim', [0 360], 'FontSize', 30);
			xlabel( 'Fist saccade direction (\circ)', 'FontSize', 30 );
			ylabel( 'Second saccade direction (\circ)', 'FontSize', 30 );
			% title( 'First saccade VS Second saccade (from cue onset)', 'FontSize', 30 );
			title( 'First saccade VS Second saccade (from target onset)', 'FontSize', 30 );	%%%%%% for color cue
			colormap('hot');
			colorbar;
		end

		function [ tTicks, rate ] = ShowMicroSacsRate( folder, monkey )
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			% respLoc = [microSacs.responseLoc];
			% % meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			% % meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% % % microSacs = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% % % microSacs = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );

			% amplitude = [microSacs.responseAmp];
			% meanL = mean( amplitude( respLoc(1,:) < 0 ) );
			% meanR = mean( amplitude( respLoc(1,:) > 0 ) );
			% % microSacs = microSacs( respLoc(1,:) < 0 & amplitude < meanL | respLoc(1,:) > 0 & amplitude < meanR );
			% microSacs = microSacs( respLoc(1,:) < 0 & amplitude > meanL | respLoc(1,:) > 0 & amplitude > meanR );

			% microSacs = MyMethods.Get1stAfter( microSacs, 'tRf', MyMethods.GetTStart( monkey, 'Mem' ) );
			microSacs = MyMethods.Get1stAfter( microSacs, 'tCue', MyMethods.GetTStart( monkey, 'ASC' ) );

			rfLoc = [microSacs.rfLoc];
			rfy1 = rfLoc(2,1:2:end);
			rfy2 = rfLoc(2,2:2:end);
			% microSacs = microSacs( rfy1 ~= rfy2 );

			% microSacs = microSacs( [microSacs.amplitude] < 1 );

			latency = [microSacs.responseLat];
			% microSacs = microSacs(latency>0.1);

            nTrials = size( unique( [microSacs.trialIndex] ), 2 );
            nTrials = microSacs(end).trialIndex;
            t_step = 0.001;
            t = [microSacs.latency] - [microSacs.tCue];
            % t = [microSacs.latency] - [microSacs.tRf];	%%%%%% for color cue or memory
            tTicks = min(t) : t_step : max(t);
            % rate = ToolKit.Hist( t, min(t) - t_step/2 : t_step : max(t) + t_step/2, false );
            rate = ToolKit.Hist( t, [ tTicks - t_step/2, tTicks(end) + t_step/2 ], false );
            SIGMA = 5;
            func = @(x) exp( -.5*(x/SIGMA).^2 ) / ( sqrt(2*pi)*SIGMA );
            rate = conv( rate, ones(1,5)/5/0.001/nTrials, 'same' );
            % rate = conv( rate, func(-200:200)/0.001/nTrials, 'same' );
            figure; hold on;
            FONTSIZE = 36;
            plot( min(t) : t_step : max(t), rate );
            plot( [0 0], get( gca, 'ylim' ), 'k:' );
            set( gca, 'FontSize', FONTSIZE );
            xlabel( 'Time from cue on (s)', 'FontSize', FONTSIZE );
            ylabel( 'Microsaccades rate (Hz)', 'FontSize', FONTSIZE );
            hold off;
		end

		function params = AmplitudeFitting( folder, monkey, task, fitKernel, isUni )
			if( nargin() <= 3 ) fitKernel = 'gev'; end
			if( nargin() <= 4 ) isUni = false; end

			%% collect data
			% if( strcmp( monkey, 'abao' ) )
			% 	global abaoMicroSacs;
			% 	if( isempty(abaoMicroSacs) )
			% 		abaoMicroSacs = MyMethods.LoadMicroSacs( 'D:\data\cue_task_refinedmat\abao\cue\PopulationData\rawdata' );
			% 	end
			% 	microSacs = abaoMicroSacs;
			% elseif( strcmp( monkey, 'datou' ) )
			% 	global datouMicroSacs;
			% 	if( isempty(datouMicroSacs) )
			% 		datouMicroSacs = MyMethods.LoadMicroSacs( 'D:\data\cue_task_refinedmat\datou\cue\PopulationData\rawdata' );
			% 	end
			% 	microSacs = datouMicroSacs;
			% end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end
			
			if( strcmpi( monkey, 'abao' ) )
            	if( strcmpi( task, 'asc' ) )
            		tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
            		index = [microSacs.latency] - [microSacs.tCue] > tStart;
            	elseif( strcmpi( task, 'cc' ) )
					tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
					index = [microSacs.latency] - [microSacs.tRf] > tStart;
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.103 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.106 smoothed with a Gaussian)
					index = [microSacs.latency] - [microSacs.tRf] > tStart;
				end
			elseif( strcmpi( monkey, 'datou' ) )
				if( strcmpi( task, 'asc' ) )
					tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
					index = [microSacs.latency] - [microSacs.tCue] > tStart;
				elseif( strcmpi( task, 'cc' ) )
					tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
					index = [microSacs.latency] - [microSacs.tRf] > tStart;
				elseif( strcmpi( task, 'mem' ) )
					tStart = 0.128 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.124 smoothed with a Gaussian)
					index = [microSacs.latency] - [microSacs.tRf] > tStart;
				end
			else
				return;
			end

			microSacs = microSacs(index);
			
			trialIndex = [microSacs.trialIndex];
			microSacs( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];

			tarLoc = [microSacs.tarLoc];
			microSacs( tarLoc(2,:) ~= 0 ) = [];
			amplitude = double( [ microSacs.amplitude ] );
			% amplitude = log(amplitude);
			% amplitude(amplitude>3) = [];
			% amplitude = amplitude(1:10:end);
			% amplitude = round( amplitude * 10 );
			% amplitude = amplitude / ( max(amplitude) + 1 );
			% amplitude(amplitude==0|amplitude==1) = [];

			disp( [ 'data mean: ', num2str( mean(amplitude) ) ] );
			disp( [ 'data std:  ', num2str( std(amplitude) ) ] );

			if( isUni )
				distName1 = fitKernel(4:end);
				distName2 = fitKernel(4:end);
				pd = fitdist( amplitude', distName1 );
				params = num2cell( [ 1 pd.Params ] );
				ind = 1;
			end

			switch( fitKernel )
				case { 'unigev' }					
					iParams = [ 2, 4; 2, 4 ];
					pdffun = @(x, w, param1, param2, param3) pdf( distName1, x, param1, param2, param3 );
					cdffun = @(x, w, param1, param2, param3) cdf( distName1, x, param1, param2, param3 );

				case { 'unilogn', 'unibeta' }
					iParams = [ 2, 3; 2, 3 ];
					pdffun = @(x, w, param1, param2) pdf( distName1, x, param1, param2 );
					cdffun = @(x, w, param1, param2) cdf( distName1, x, param1, param2 );

				case 'gev'
					%% define cdf and pdf
					distName1 = 'gev';
					distName2 = 'gev';
					pdffun = @(x, w, param1, param2, param3, param4, param5, param6) w * pdf( distName1, x, param1, param2, param3 ) + (1-w) * pdf( distName2, x, param4, param5, param6 );
					cdffun = @(x, w, param1, param2, param3, param4, param5, param6) w * cdf( distName1, x, param1, param2, param3 ) + (1-w) * cdf( distName2, x, param4, param5, param6 );
					iParams = [ 2, 4; 5, 7 ];

					%% set bounds;
					% lowerbounds = [ 0 -0.2 std(amplitude)/5 0 -0.2 std(amplitude)/5 0 ];
					% upperbounds = [ 1 1 std(amplitude) mean(amplitude) 1 std(amplitude) 3 ];
					lowerbounds = [ 0 -0.2 std(amplitude)/5 0 -0.3 0.5 1.5 ];
					lowerbounds = [ 0 -0.05 std(amplitude)/5 0 -0.3 0.3 1.5 ];
                    upperbounds = [ 1 1 std(amplitude) mean(amplitude) 1 std(amplitude) 4 ];
					% upperbounds([2,5]) = lowerbounds([3,6]) / ( upperbounds([4,7]) - min(amplitude) );
				case 'lognormal'
					distName1 = 'lognormal';
					distName2 = 'lognormal';
					pdffun = @(x, w, param1, param2, param3, param4) w * pdf( distName1, x, param1, param2 ) + (1-w) * pdf( distName2, x, param3, param4 );
					cdffun = @(x, w, param1, param2, param3, param4) w * cdf( distName1, x, param1, param2 ) + (1-w) * cdf( distName2, x, param3, param4 );
					iParams = [ 2, 3; 4, 5 ];

					lowerbounds = [ 0 0 std(amplitude)/5 0 std(amplitude)/5 ];
					upperbounds = [ 1 mean(amplitude) std(amplitude) 3 std(amplitude)];
				case 'gevlogn'
					distName1 = 'gev';
					distName2 = 'lognormal';
					pdffun = @(x, w, param1, param2, param3, param4, param5) w * pdf( distName1, x, param1, param2, param3 ) + (1-w) * pdf( distName2, x, param4, param5 );
					cdffun = @(x, w, param1, param2, param3, param4, param5) w * cdf( distName1, x, param1, param2, param3 ) + (1-w) * cdf( distName2, x, param4, param5 );
					iParams = [ 2, 4; 5, 6 ];

					lowerbounds = [ 0 -0.2 std(amplitude)/5 0 0 std(amplitude)/5 ];
					upperbounds = [ 1 1 std(amplitude) mean(amplitude) 3 std(amplitude) ];
					upperbounds(2) = lowerbounds(3) / ( upperbounds(4) - min(amplitude) );
				case 'logngev'
					distName1 = 'lognormal';
					distName2 = 'gev';
					pdffun = @(x, w, param1, param2, param3, param4, param5) w * pdf( distName1, x, param1, param2 ) + (1-w) * pdf( distName2, x, param3, param4, param5 );
					cdffun = @(x, w, param1, param2, param3, param4, param5) w * cdf( distName1, x, param1, param2 ) + (1-w) * cdf( distName2, x, param3, param4, param5 );
					iParams = [ 2, 3; 4, 6 ];

					lowerbounds = [ 0 0 std(amplitude)/5 -0.2 std(amplitude)/5 0 ];
					upperbounds = [ 1 mean(amplitude) std(amplitude) 1 std(amplitude) 3 ];
					% upperbounds(4) = lowerbounds(5) / ( upperbounds(6) - min(amplitude) );

				otherwise
					disp( 'Unrecognized fitting kernel!!!' );
					return;
			end


			chi2_p = 0;
			ks_p = 0;

			if( ~isUni )
				%% fit & test
				init = lowerbounds;
	            starts = init;
				params = num2cell(init);
				
				options = statset( 'display', 'off', 'MaxIter', 100000, 'MaxFunEvals', 200000, 'FunValCheck', 'off' );
				nIters = 0;
				starts_history = [];
				while( nIters < 50 && ( chi2_p(end) < 0.05 || ks_p(end) < 0.05 ) && any( abs( [params{end,:}] - upperbounds ) > 0.0001 ) )%starts(2) < upperbounds(2) / 2 )
					%% fit
					if( size(params,1) > 1 && all( abs( [params{end-1,:}] - [params{end,:}] ) < 0.0001 ) )
						% init = init + 0.1;
						% starts = min( [ init; upperbounds ] );
						starts = min( [ [params{end,:}] + 0.01; upperbounds ] );
						isTrapped = false;
						for( i = 1 : size(starts_history,1) )
							if( all( starts_history(i,:) - starts < 0.001 ) )
								isTrapped = true;
							end
						end
						if( isTrapped ) break; end
						starts_history(end+1,:) = starts;
					else
						starts = [params{end,:}];
					end
					starts
					params(end+1,:) = num2cell( mle( amplitude, 'pdf', pdffun, 'start', starts, 'lowerbound', lowerbounds, 'upperbound', upperbounds, 'optimfun', 'fmincon', 'options', options ) );
					params(end,:)

					%% test
					amplitude = sort(amplitude);
		            edges = unique( [ amplitude( 1 : max([5,ceil(size(amplitude,2)/100)]) : end ), amplitude(end) ] );
					[ chi2_h, chi2_p(end+1), chi2_st ] = chi2gof( amplitude, 'cdf', [ {cdffun}, params(end,:) ], 'edges', edges );
					[ ks_h, ks_p(end+1), ks_st, ks_cv ] = kstest( amplitude, [ unique(amplitude)', cdffun( unique(amplitude)', params{end,:} ) ] );
					chi2_p(end)
					ks_p(end)
					
					% break;
					nIters = nIters + 1;
				end

				[~, ind] = max( chi2_p + ks_p );
				params = params( ind, : )
				% params = { 0.3268, 0.0347, 0.2333, 0.6907, 1.0000e-6, 0.5709, 1.6908 };
			end

			%% test
			amplitude = sort(amplitude);
            edges = unique( [ amplitude( 1 : max([5,ceil(size(amplitude,2)/100)]) : end ), amplitude(end) ] );
			[ chi2_h, chi2_p(end), chi2_st ] = chi2gof( amplitude, 'cdf', [ {cdffun}, params(end,:) ], 'edges', edges );
			[ ks_h, ks_p(end), ks_st, ks_cv ] = kstest( amplitude, [ unique(amplitude)', cdffun( unique(amplitude)', params{end,:} ) ] );

			%% plot
			figure; hold on;
			set( gcf, 'NumberTitle', 'off', 'name', [ 'AmplitudeDistribution_', monkey, '__', fitKernel ] );

			amp_step = .1;
			edges = min(amplitude) - amp_step/2 : amp_step : max(amplitude) + amp_step/2;
			ToolKit.Hist( amplitude, edges, true, true );

			% plot( log( ( edges(1:end-1) + edges(2:end) ) / 2 ), log(ToolKit.Hist(amplitude,edges,false)) ); return;
			
			set( gca, 'xlim', [0 10] );
			set(get(gca,'child'),'LineStyle','none');
			ToolKit.BorderText( 'InnerTopRight', sprintf( 'nTrials: %d', size( unique([microSacs.trialIndex]), 2 ) ), 'FontSize', 12 );

			% X = ( edges(1:end-1) + edges(2:end) ) / 2;
			X = edges(1) : 0.001 : edges(end);
			h(1) = plot( X, amp_step * pdffun( X, params{:} ), 'r', 'LineWidth', 2 );
			h(2) = plot( X, amp_step * params{1} * pdf( distName1, X, params{ iParams(1,1) : iParams(1,2) } ), 'g--', 'LineWidth', 2 );
			h(3) = plot( X, amp_step * ( 1 - params{1} ) * pdf( distName2, X, params{ iParams(2,1) : iParams(2,2) } ), 'y--', 'LineWidth', 2 );
			legend( h, 'sum', 'first', 'second', 'location', 'east' );

			ToolKit.BorderText( 'InnerTop', sprintf( [ ...
				'chi2gof: p = %.4f\n'...
				'    kstest: p = %.4f\n'...
				'params: ', repmat('%.4f ',1,size(params,2)) '\n'...
				'First: %.4f    Second: %.4f' ],...
				chi2_p(ind), ks_p(ind), [params{:}],...
				params{1} * cdf( distName1, 1, params{ iParams(1,1) : iParams(1,2) } ),...
				( 1 - params{1} ) * cdf( distName2, 1, params{ iParams(2,1) : iParams(2,2) } ) ), 'FontSize', 12 );
			if( strcmp( fitKernel, 'gev' ) )
				y = get(gca,'ylim');
				text( 0, y(2), sprintf('$f(x)=%.3fgevpdf(x,%.3f,%.3f,%.3f)+%.3fgevpdf(x,%.3f,%.3f,%.3f)$',params{1:4},1-params{1},params{5:7}), 'interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'bottom' );
			end
			xlabel( 'Saccade amplitude (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			return;
		end

		function ShowMemoryPopulation( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowmemoryPopulation( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end
            index = [];
            for( i = 1 : size(microSacs,2) )
                if( size( microSacs(i).rfLoc, 2 ) > 1 )
                    index = [index,i];
                end
            end
            % microSacs(index) = [];

            if( strcmpi( monkey, 'abao' ) )
				tStart = 0.103 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.106 smoothed with a Gaussian)
			elseif( strcmpi( monkey, 'datou' ) )
				tStart = 0.128 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.124 smoothed with a Gaussian)
			else
				return;
			end

            % tStart = 0.2;

			index1 = find( [microSacs.latency] - [microSacs.tRf] > tStart );
			trialIndex = [microSacs(index1).trialIndex];
			index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
			index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
			trialIndex = [microSacs(index2).trialIndex];
			index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

			microSacs(index2) = [];	% 1st sacs
			% microSacs([index1,index3]) = [];	% 2nd sacs
			% microSacs = microSacs(index3);

			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );%& [microSacs.latency] - [microSacs.tCue] > tStart );

			% figure;
			% hist( [microSacs.angle], [-180:5:180] );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', monkey, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
			
			tarLoc = round([microSacs.tarLoc]);
			rfLoc = [microSacs.rfLoc];
			% index = [ rfLoc(1,:) > 0; rfLoc(1,:) < 0; rfLoc(2,:) > 0; rfLoc(2,:) < 0 ];
			% index = [ tarLoc(1,:) < 0 & tarLoc(2,:) == 0; tarLoc(1,:) > 0 & tarLoc(2,:) == 0 ];
			% index = [ tarLoc(2,:) < -5 & abs(tarLoc(1,:)) < 5; tarLoc(2,:) > 5 & abs(tarLoc(1,:)) < 5 ];
			index = logical([...
						tarLoc(1,:) < -5 & tarLoc(2,:) > 5;...
						abs(tarLoc(1,:)) < 5 & tarLoc(2,:) > 5;...
						tarLoc(1,:) > 5 & tarLoc(2,:) > 5;...
						...
						tarLoc(1,:) < -5 & abs(tarLoc(2,:)) < 5;...
						zeros( size(microSacs) );...
						tarLoc(1,:) == 10 & abs(tarLoc(2,:)) < 5;...
						...
						tarLoc(1,:) < -5 & tarLoc(2,:) < -5;...
						abs(tarLoc(1,:)) < 5 & tarLoc(2,:) < -5;...
						tarLoc(1,:) > 5 & tarLoc(2,:) < -5;...
					]);

			tIndex = index(1,:);
			for( i = 2 : size(index,1) );
				tIndex = tIndex | index(i,:);
			end
			t = [microSacs(tIndex).latency] - [microSacs(tIndex).tRf];
			t_step = 0.01;
			ang_step = 2;
			edges = { -0.22 : t_step : max(t) + t_step/2, -180 : ang_step : 180 };
			edges = { -0.22 : t_step : max(t) + t_step/2, 0 : ang_step : 360 };
			edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };

			%% show raw data
			cmax = 0;
			for( i = 1 : size(index,1) )
				if( i == 5 ) continue; end
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				ang = [microSacs(index(i,:)).angle];
				ang(ang<0) = ang(ang<0) + 360;
				cdata = hist3( [t; ang]', 'edges', edges );
				tmax = max(max(cdata));
				if( cmax < tmax ) cmax = tmax; end
			end
			% colormap( [ ones(cmax+1,1), repmat( [ 1, ( 1 - (1:cmax)/cmax ) / 1.2 ]', 1, 2 ) ] );
			colormap('hot');
			% cmp = colormap;
			% colormap( cmp( round( [0:cmax] * ( size(cmp,1) - 1 ) / cmax ) + 1, : ) );
			cmp = colormap;

			for( i = 1 : size(index,1) )
				if( i == 5 ) continue; end
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				ang = [microSacs(index(i,:)).angle];
				ang(ang<0) = ang(ang<0) + 360;

				% subplot(2,2,i); hold on;
				subplot(3,3,i); hold on;
				% edges = { min(t) - t_step/2 : t_step : max(t) + t_step/2, -180 : ang_step : 180 };
				% edges = { -0.4 : t_step : 1.2, -180 : ang_step : 180 };
				% edges = { -0.2 : t_step : max(t) + t_step/2, -180 : ang_step : 180 };
				%hist3( [t; ang]', 'edges', edges );
				cdata = hist3( [t; ang]', 'edges', edges )';
	            if( ~isempty(cdata) )
	                % set( pcolor( edges{1}, edges{2}, cdata' ), 'LineStyle', 'none' );
	                nColors = size(cmp,1) - 1;
	                colour = reshape( cmp( round( cdata * nColors / cmax ) + 1 , : ), [ size(cdata), 3 ] );
	                image( edges{1}, edges{2}, colour );
	            end
	            pause(0.6);
	            % colorbar;
	            tCMAX = caxis;
	            if( cmax < tCMAX(2) ) cmax = tCMAX(2); end

	            % show -90, 0, 90 degrees
	            for( k = 90 : 90 : 270 )
	            	plot( [ edges{1}(1), edges{1}(end) ], [k k], 'w:' );
	            end

	            % show tar angles
				angs = cart2pol( rfLoc(1,index(i,:)), rfLoc(2,index(i,:)) ) / pi * 180;
				y = zeros( 1, size(angs,2)*3 ) * NaN;
				y( 1 : 3 : end-2 ) = angs;
				y( 2 : 3 : end-1 ) = angs;
				x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
				% plot( x, y, ':', 'color', [0 0.4 0] );
				set( gca, 'layer', 'top', 'XColor', 'w', 'YColor', 'w', 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [0:90:360] );

				% % show a center window for the angles
				% win = 10;
				% fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

				%% time points of several events				
				% rf on time
                y = get( gca, 'ylim' );
				plot( [0 0], y, 'g:' );
				text( 0, y(2), 'target', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12 );

				% rf off time
				% plot( [0.2 0.2], y, 'w:' );
				% text( 0.2, y(2)-15, 'target off', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12 );

				% number of trials
				x = get(gca,'xlim');
				text( x(2), y(2), sprintf( 'nTrials: %d', size(unique([microSacs(index(i,:)).trialIndex]),2) ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );
				
				
				xlabel( [ 'Time from ', 'target on (s)' ], 'FontSize', 12 );
				ylabel( [ 'Microsaccade direction (\circ)' ], 'FontSize', 12 );
				continue;


				%% countour fitting
				tmpAng 	= ang( t > tStart );
				tmpT	= t( t > tStart ) * 1000;
				obj = gmdistribution.fit( [tmpT',tmpAng'], 2, 'Options', statset( 'Display', 'final' ) );
				h = ezcontour( @(x,y) pdf( obj, [x*1000,y] ), double([edges{1}(1) edges{1}(end)]), [ edges{2}(1) edges{2}(end) ] );

				continue;


				%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
				%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
				nUp	  = sum( ang > 0 & t > tStart );
				nDown = sum( ang < 0 & t > tStart );
				label = [];
				ratio = 0;
				angRange = 0:180;
				if( strcmp( monkey, 'datou' ) )
					tmpIndex = ang < 180 & t > tStart;
					ratio = nUp / ( nUp + nDown );
					label = '_{up}';
				elseif( strcmp( monkey, 'abao' ) )
					tmpIndex = ang > 180 & t > tStart;
					ratio = nDown / ( nUp + nDown );
					label = '_{down}';
					angRange = 180:360;
				end
				
				%edges{1}(end) = 0.5;
				tmpAng = ang(tmpIndex);
				tmpT = t(tmpIndex);
				p = polyfit( tmpT, tmpAng, 1);
				[r pval] = corrcoef( tmpT, tmpAng );
				plot( [tStart, edges{1}(end)], polyval( p, [tStart, edges{1}(end)] ), 'b', 'LineWidth', 2 );
				text( 0.25, 0-20, [ 'k', label, ' = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.25, 0-50, [ 'r', label, ' = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.7, 0-50, [ 'p', label, ' = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

				%% Show the averaged curve
				cdata = hist3( [tmpT; tmpAng]', 'edges', { tStart : t_step : edges{1}(end), angRange } )';
				plot( tStart : t_step : edges{1}(end), ( angRange * cdata ) ./ ( ones(1,181) * cdata ), 'c', 'LineWidth', 1 );
				
				text( 0.7, 0-20, [ 'ratio', label, ' = ', sprintf('%7.4f',ratio) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

	        end
            % colormap('hot');
            % for( i = 1 : size( index, 1 ) )
            % 	subplot(2,2,i);
            % 	caxis( [ 0, cmax ] );
            % end
		end

		function MemBias = MemBiasAnalyzer( folder, monkey, ang_step, ang_win )
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 20; end

			if( exist( [folder,'\bias\MemBias.mat'], 'file' ) == 2 )
				load( [folder,'\bias\MemBias.mat'] );
			else
				diary( [folder,'\bias\diary.txt'] );
				MemBias = [];
				years = ToolKit.ListFolders( folder );
				for( iYear = 1 : size(years,1) )
					months = ToolKit.ListFolders( ToolKit.RMEndSpaces(years(iYear,:)) );
					for( iMonth = 1 : size(months,1) )
						month = ToolKit.RMEndSpaces(months(iMonth,:));
						MemBias(end+1).name = month( find( month == '\', 1, 'last' ) + 1 : end );
						
						mem = BlocksAnalyzer( 'MemBlock', ToolKit.ListMatFiles(month) );
						
						MemBias(end).fp2rf.angles	= [];	% angles for breaks after fixation point on before candidate targets on
						MemBias(end).fp2rf.time		= [];	% break time aligned to fp on
						MemBias(end).rf2j1.angles	= [];	% angles for breaks after cue on when target is on the left side
						MemBias(end).rf2j1.ePoints	= [];	% saccade end points
						MemBias(end).rf2j1.time		= [];	% break time aligned to cue on
						MemBias(end).rf2j1.tarLocs	= [];	% target location when break
						MemBias(end).errors.angles	= [];	% angles for errors when target is on the left side
						MemBias(end).errors.ePoints	= [];	% saccade end points
						MemBias(end).errors.time	= [];	% saccade time aligned to jmp1 on
						MemBias(end).errors.tarLocs = [];	% target location when error
						MemBias(end).nBreaks			= zeros(1,8);	% number of breaks for each target location
						MemBias(end).nErrors			= zeros(1,8);	% number of errors for each target location
						MemBias(end).nCorrect		= zeros(1,8);	% number of correct trials for each target location
						for( iBlock = mem.nBlocks : -1 : 1 )
							breaks = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
							if( ~isempty(breaks) )
								%% for MemBias(end).fp2rf
								fp = [breaks.fp];
								rf = [breaks.rf];
								trials = breaks( [fp.tOn] > 0 & [rf.tOn] < 0 );
								if( ~isempty(trials) )
									[ tBreak, breakSacs ] = trials.GetBreak();
									fp = [trials.fp];
									% tIndex = tBreak > [fp.tOn] + 0.25;	% tmp index of breaks 250ms after fp on
									MemBias(end).fp2rf.angles = [ MemBias(end).fp2rf.angles, [breakSacs.angle] ];
									MemBias(end).fp2rf.time = [ MemBias(end).fp2rf.time, tBreak - [fp.tOn] ];
								end

								%% for MemBias(end).rf2j1
								rf = [breaks.rf];
								jmp1 = [breaks.jmp1];
								trials = breaks( [rf.tOn] > 0 & [jmp1.tOn] < 0 );
								if( ~isempty(trials) )
									rf = [trials.rf];
									
									[ tBreak, breakSacs ] = trials.GetBreak;
									MemBias(end).rf2j1.angles = [ MemBias(end).rf2j1.angles, breakSacs.angle ];
									MemBias(end).rf2j1.time = [ MemBias(end).rf2j1.time, tBreak - [rf.tOn] ];
									MemBias(end).rf2j1.tarLocs = [ MemBias(end).rf2j1.tarLocs, [ rf.x; rf.y ] ];
									ePoints = [breakSacs.termiPoints];
									if( ~isempty(ePoints) )
										MemBias(end).rf2j1.ePoints = [ MemBias(end).rf2j1.ePoints, ePoints(:,2) ];
									end

									x = [rf.x];
									y = [rf.y];
									tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
									for( i = 1 : 8 )
										MemBias(end).nBreaks(i) = MemBias(end).nBreaks(i) + sum(tIndex(i,:));
									end
								end
							end

							%% for MemBias(end).errors
							trials = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.ERROR );
							if( ~isempty(trials) )
								jmp1 = [trials.jmp1];
								x = [jmp1.x];
								y = [jmp1.y];
								tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
								for( i = 1 : 8 )
									MemBias(end).nErrors(i) = MemBias(end).nErrors(i) + sum(tIndex(i,:));
								end
								j1win = 2.5;
								for( trial = trials )
									endPoint = trial.saccades(trial.iResponse1).termiPoints(:,2);
									% if( ~inpolygon( endPoint(1), endPoint(2), [ -j1win j1win j1win -j1win -j1win ] + trial.jmp1.x, [ -j1win -j1win j1win j1win -j1win ] + trial.jmp1.y ) )
										MemBias(end).errors.angles = [ MemBias(end).errors.angles, trial.saccades(trial.iResponse1).angle ];
										MemBias(end).errors.ePoints = [ MemBias(end).errors.ePoints, trial.saccades(trial.iResponse1).termiPoints(:,2) ];
										MemBias(end).errors.time = [ MemBias(end).errors.time, trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn ];
										MemBias(end).errors.tarLocs = [ MemBias(end).errors.tarLocs, [jmp1.x;jmp1.y] ];										
									% end
								end
							end

							%% for correct
							trials = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT );
							if( ~isempty(trials) )
								jmp1 = [trials.jmp1];
								x = [jmp1.x];
								y = [jmp1.y];
								tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
								for( i = 1 : 8 )
									MemBias(end).nCorrect(i) = MemBias(end).nCorrect(i) + sum(tIndex(i,:));
								end
							end
						end
						% if( MemBias(end).nLeftCorrect == 0 && MemBias(end).nRightCorrect == 0 ) MemBias(end) = []; end

					end					
                end
                diary off;
                mkdir( [folder,'\bias'] );
				save( [folder,'\bias\MemBias.mat'], 'MemBias' );
			end

			%% fp2rf
			%% get data
			% for population
			angles = [];
			time = [];
			for( i = 1 : size(MemBias,2) )
				time = [ time, MemBias(i).fp2rf.time ];
				angles = [ angles, MemBias(i).fp2rf.angles( MemBias(i).fp2rf.time > 0.25 ) ];		% only use breaks 250ms after fixation on
			end

			% for significance
			tIndex = false(size(MemBias));
			for( i = size(MemBias,2) : -1 : 1 )
				tAngs = MemBias(i).fp2rf.angles( MemBias(i).fp2rf.time > 0.25 );
				if( isempty(tAngs) )
					tIndex(i) = true;
                    left(i) = NaN;
                    right(i) = NaN;
					continue;
				end
				left(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				right(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
			end
			left(tIndex) = [];
			right(tIndex) = [];

			%% names, labels...
			figName = [ monkey,' Breaks After Fp On Before Candidates On' ];
			figDirectTitle = 'Direction distribution of break saccades before candidates on';
			figTimeTitle = 'Time distribution of break saccades before candidates on';
			

			%% figure for population
			set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Population)' ] );

			% time distribution
			subplot(2,2,1);
			t_step = 0.01;
			[data, ax] = hist( time, min(time) - t_step/2 : t_step : max(time) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			xlabel( 'Break time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( figTimeTitle, 'FontSize', 12 );
			
			% direction polar plot
			subplot(2,2,2);			
			polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
			title( figDirectTitle, 'FontSize', 12 );

			% direction hist plot
			subplot(2,2,3);
			[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( figDirectTitle, 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;
			bar( 1, sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2), 0.5, 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles & angles < ang_win ) / size(angles,2), 0.5, 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			%% figure for significance
			set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			plot( left, right, 'k:*' );
			plot( left(1), right(1), 'r*' );
			axis('equal');
			set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
			ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(left), 0.5, 'g' );
			errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(right), 0.5, 'r' );
			errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			if( mean(left) < mean(right) )	tail = 'left';
			else 							tail = 'right'; end
			text( 2.7, 0.9, sprintf( 'p = %f\ntail: %s', signrank( left, right, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			return;

			%% cue2j1 break ratio to all breaks: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			for( i = 1 : size(MemBias,2) )
				time.left = [ time.left, MemBias(i).cue2j1.tarLeft.time ];
				time.right = [ time.right, MemBias(i).cue2j1.tarRight.time ];
				angles.left = [ angles.left, MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound ) ];
				angles.right = [ angles.right, MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound ) ];
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Population)' ] );
			
			% time distribution
			subplot(2,2,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xlim', [0 0.65] )
			xlabel( 'Break time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Time distribution of break saccades after cue on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,2,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction hist plot
			subplot(2,2,3); hold on;
			[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;			
			bar( 1, sum( angles.left < -180 + ang_win | angles.left > 180 - ang_win ) / size(angles.left,2), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles.right & angles.right < ang_win ) / size(angles.right,2), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / size(angles.right,2), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum( -ang_win < angles.left & angles.left < ang_win ) / size(angles.left,2), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			title( sprintf( 'Break ratio to all breaks (Window: +-%d\\circ)', ang_win ), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% cue2j1 break ratio to all breaks: significance
			% get data
			for( i = size(MemBias,2) : -1 : 1 )
				tAngs = MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				tAngs = MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound );
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Break ratio to all breaks (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% cue2j1 break ratio to all trials
			% get data
			nLeftBreaks = sum( [MemBias.nLeftBreaks] );
			nLeftErrors = sum( [MemBias.nLeftErrors] );
			nLeftCorrect = sum( [MemBias.nLeftCorrect] );
			nRightBreaks = sum( [MemBias.nRightBreaks] );
			nRightErrors = sum( [MemBias.nRightErrors] );
			nRightCorrect = sum( [MemBias.nRightCorrect] );
			for( i = size(MemBias,2) : -1 : 1 )
				NLeft(i) = MemBias(i).nLeftBreaks + MemBias(i).nLeftErrors + MemBias(i).nLeftCorrect;		% number of target left trials
				NRight(i) = MemBias(i).nRightBreaks + MemBias(i).nRightErrors + MemBias(i).nRightCorrect;	% number of target right trials
				tAngs = MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound );
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target left
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target left
				tAngs = MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target right
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target right
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Trials After Cue On (Ratio)' ] );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );

			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( sprintf('Break ratio to all trials (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			% dots plot
			LL = LL./NLeft;
			RR = RR./NRight;
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,[1 2 4 5]); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Month by month break ratio (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 0.1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% errors: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			j1win = 2.5;
			for( i = size(MemBias,2) : -1 : 1 )
				time.left = [ time.left, MemBias(i).cue2j1.tarLeft.time( MemBias(i).cue2j1.tarLeft.time > tBound ) - 0.6, MemBias(i).errors.tarLeft.time ];
				time.right = [ time.right, MemBias(i).cue2j1.tarRight.time( MemBias(i).cue2j1.tarRight.time > tBound ) - 0.6, MemBias(i).errors.tarRight.time ];
				angles.left = [ angles.left, MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time > tBound ), MemBias(i).errors.tarLeft.angles ];
				angles.right = [ angles.right, MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time > tBound ), MemBias(i).errors.tarRight.angles ];
				
				LL(i) = MemBias(i).nLeftCorrect;
				RR(i) = MemBias(i).nRightCorrect;
				LR(i) = 0;
				RL(i) = 0;
				for( m = 1 : size( MemBias(i).cue2j1.tarLeft.ePoints, 2 ) )
					if( MemBias(i).cue2j1.tarLeft.time(m) > tBound )
						if( inpolygon( MemBias(i).cue2j1.tarLeft.ePoints(1,m), MemBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LL(i) = LL(i) + 1;
						elseif( inpolygon( MemBias(i).cue2j1.tarLeft.ePoints(1,m), MemBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LR(i) = LR(i) + 1;
						end
					end
				end
				for( m = 1 : size( MemBias(i).errors.tarLeft.ePoints, 2 ) )
					if( inpolygon( MemBias(i).errors.tarLeft.ePoints(1,m), MemBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LL(i) = LL(i) + 1;
					elseif( inpolygon( MemBias(i).errors.tarLeft.ePoints(1,m), MemBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LR(i) = LR(i) + 1;
					end
				end
				for( m = 1 : size( MemBias(i).cue2j1.tarRight.ePoints, 2 ) )
					if( MemBias(i).cue2j1.tarRight.time(m) > tBound )
						if( inpolygon( MemBias(i).cue2j1.tarRight.ePoints(1,m), MemBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RL(i) = RL(i) + 1;
						elseif( inpolygon( MemBias(i).cue2j1.tarRight.ePoints(1,m), MemBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RR(i) = RR(i) + 1;
						end
					end
				end
				for( m = 1 : size( MemBias(i).errors.tarRight.ePoints, 2 ) )
					if( inpolygon( MemBias(i).errors.tarRight.ePoints(1,m), MemBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RL(i) = RL(i) + 1;
					elseif( inpolygon( MemBias(i).errors.tarRight.ePoints(1,m), MemBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RR(i) = RR(i) + 1;
					end
				end

			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Error ratio' ] );
			
			% time distribution
			subplot(2,3,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			xlabel( 'Response time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Time distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,3,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( 'Correct ratio & Error ratio: Population', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			LL = LL./NLeft;
			RR = RR./NRight;
			subplot(2,3,4); hold on;
			plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			axis('equal');
			ymin = min( [ LL, RR ] ) * 0.7;
			ymax = max( [ LL, RR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target left  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target right', 'FontSize', 12 );
			title( 'Month by month response ratio: LL.VS.RR', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,5); hold on;
			plot( RL, LR, 'm:s', 'DisplayName', 'LL.VS.RR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ RL, LR ] ) * 0.7;
			ymax = max( [ RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target right  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target left (%)', 'FontSize', 12 );
			title( 'Month by month response ratio: RL.VS.LR', 'FontSize', 12 );

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( 'Correct ratio & Error ratio: Significance test', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			return;
		end

		function ShowColorCuePopulation( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowColorCuePopulation( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end
			
            % index = [];
            % for( i = 1 : size(microSacs,2) )
            %     if( size( microSacs(i).rfLoc, 2 ) ~= 2 )
            %         index = [index,i];
            %     end
            % end
            % microSacs(index) = [];

            if( strcmp( monkey, 'abao' ) )
				tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
			else
				return;
			end

            % tStart = 0.05;

            microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > -.22 );

			index1 = find( [microSacs.latency] - [microSacs.tRf] > tStart );
			trialIndex = [microSacs(index1).trialIndex];
			index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
			index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
			trialIndex = [microSacs(index2).trialIndex];
			index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

			microSacs(index2) = [];	% 1st sacs
			% microSacs([index1,index3]) = [];	% 2nd sacs
			% microSacs = microSacs(index3);

			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );%& [microSacs.latency] - [microSacs.tCue] > tStart );

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			nGroups = 3;
			N = floor( size(microSacs,2) / nGroups );
			% microSacs = microSacs( N*0+1 : N*1 );

			% figure;
			% hist( [microSacs.angle], [-180:5:180] );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', monkey, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

			t_step = 0.01;
			ang_step = 2;

			tarLoc = [microSacs.tarLoc];
			rfLoc = [microSacs.rfLoc];
			index = [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ];



			%% show raw data
			edges = { -0.22 : t_step : 0.6, -180 : ang_step : 180 };
			edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };	%% for abao horizontal target
			cmax = 0;
			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				ang = [microSacs(index(i,:)).angle];
				% ang(ang<0) = ang(ang<0) + 360;	%% for abao horizontal target
				cdata = hist3( [t; ang]', 'edges', edges );
				tmax = max(max(cdata));
				if( cmax < tmax ) cmax = tmax; end
			end
			% cmax = 28;
			% colormap( [ ones(cmax+1,1), repmat( [ 1, ( 1 - (1:cmax)/cmax ) / 1.2 ]', 1, 2 ) ] );
			colormap('hot');
			% cmp = colormap;
			% colormap( cmp( round( [0:cmax] * ( size(cmp,1) - 1 ) / cmax ) + 1, : ) );
			cmp = colormap;

			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				ang = [microSacs(index(i,:)).angle];
				% if( i == 2 ) ang( ang < 0 ) = ang( ang < 0 ) + 25; end
				ang( ang < 0 ) = ang( ang < 0 ) + 360;	%% for abao horizontal target

				subplot(2,2,i); hold on;
				cdata = hist3( [t; ang]', 'edges', edges )';
	            if( ~isempty(cdata) )
	                % set( pcolor( edges{1}, edges{2}, cdata ), 'LineStyle', 'none' );
	                nColors = size(cmp,1) - 1;
	                colour = reshape( cmp( round( cdata * nColors / cmax ) + 1 , : ), [ size(cdata), 3 ] );
	                image( edges{1}, edges{2}, colour );
	            end
	            pause(0.6);
	            % colorbar;
	            % tCMAX = caxis;
	            % if( cmax < tCMAX(2) ) cmax = tCMAX(2); end

	            % set( gca, 'layer', 'top', 'XColor', 'w', 'YColor', 'w', 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [-180:90:180] );
	            set( gca, 'layer', 'top', 'XColor', 'w', 'YColor', 'w', 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [0:90:360] );	%% for abao horizontal target
				xlabel( [ 'Time from ', 'target on (s)' ], 'FontSize', 12 );
				ylabel( [ 'Microsaccade direction (\circ)' ], 'FontSize', 12 );

	            % show -90, 0, 90 degrees
	            % for( k = -90 : 90 : 90 )
	            for( k = 90 : 90 : 270 )	%% for abao horizontal target
	            	plot( [ edges{1}(1), edges{1}(end) ], [k k], 'w:' );
	            end

	            % show tar angles
				angs = cart2pol( tarLoc(1,index(i,:)), tarLoc(2,index(i,:)) ) / pi * 180;
				y = zeros( 1, size(angs,2)*3 ) * NaN;
				y( 1 : 3 : end-2 ) = angs;
				y( 2 : 3 : end-1 ) = angs;
				x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
				% plot( x, y, ':', 'color', [0 0.4 0] );

				% % show a center window for the angles
				% win = 10;
				% fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

				%% time points of several events
				% rf on time
                y = get( gca, 'ylim' );
				plot( [0 0], y, 'g:' );
				text( 0, y(2), 'target on', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			
				% number of trials
				x = get(gca,'xlim');
				text( x(2), y(2), sprintf( 'nTrials: %d', size(unique([microSacs(index(i,:)).trialIndex]),2) ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );
				% continue;

				%% countour fitting
				t_tStart = 0.24;
				tmpAng 	= ang( t > t_tStart );
				tmpT	= t( t > t_tStart ) * 1000;
				obj = gmdistribution.fit( [tmpT',tmpAng'], 2, 'Options', statset( 'Display', 'final' ) );
				h = ezcontour( @(x,y) pdf( obj, [x*1000,y] ), [-.22,0.6], [edges{2}(1) edges{2}(end)] );

				%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
				%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
				% tStart = 0.3;
				nUp	  = sum( ang < 180 & t > tStart );
				nDown = sum( ang > 180 & t > tStart );
				label = [];
				ratio = 0;
				angRange = 0:180;
				if( strcmp( monkey, 'datou' ) )
					tmpIndex = ang < 180 & t > tStart;
					ratio = nUp / ( nUp + nDown );
					label = '_{up}';
					label = [];
				elseif( strcmp( monkey, 'abao' ) )
					tmpIndex = ang > 180 & t > tStart;
					ratio = nDown / ( nUp + nDown );
					label = '_{down}';
					label = [];
					angRange = -180:0;

					angRange = -180:180;
					% tmpIndex = t > tStart;
					tmpIndex = ang > 180 & t > t_tStart;
					% tmpIndex = ang < 0 & t > t_tStart;
					angRange = 0:360;
				end
				
				%edges{1}(end) = 0.5;
				tmpAng = ang(tmpIndex);
				tmpT = t(tmpIndex);
				p = polyfit( tmpT, tmpAng, 1);
				[r pval] = corrcoef( tmpT, tmpAng );
				plot( [tStart, edges{1}(end)], polyval( p, [tStart, edges{1}(end)] ), 'b', 'LineWidth', 2 );
				text( 0.3, edges{2}(1)-20, [ 'k', label, ' = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.3, edges{2}(1)-50, [ 'r', label, ' = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.55, edges{2}(1)-50, [ 'p', label, ' = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

				%% Show the averaged curve
				cdata = hist3( [tmpT; tmpAng]', 'edges', { tStart : t_step : edges{1}(end), angRange } )';				
				plot( tStart : t_step : edges{1}(end), ( angRange * cdata ) ./ ( ones(size(angRange)) * cdata ), 'c', 'LineWidth', 1 );
				
				text( 0.55, 0-20, [ 'ratio', label, ' = ', sprintf('%7.4f',ratio) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

	        end
            % colormap('hot');
            for( i = 1 : size(index,1) )
            	% subplot(2,2,i);
            	% caxis( [ 0, cmax ] );
            end
		end

		function ShowSlices( folder, monkey, task, isOblique, ampEdges )
			if( nargin() < 3 ) disp( 'Usage: MyMethods.ShowSlices( folder, monkey, task, isOblique = false, ampEdges = [0,5] )' ); return; end
			if( nargin() == 3 ) isOblique = false; end
			if( nargin() < 4 ) ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

            tStart = MyMethods.GetTStart( monkey, task );
            if( isempty( tStart ) ) return; end

			if( strcmpi( task, 'asc' ) )
				microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );
				microSacs = MyMethods.Get1stAfter( microSacs, 'tCue', tStart );
			elseif( strcmpi( task, 'cc' ) || strcmpi( task, 'mem' ) )
            	microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > tStart );
            	microSacs = MyMethods.Get1stAfter( microSacs, 'tRf', tStart );
            end

			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );

			tarLoc = [microSacs.tarLoc];
			if( isOblique )
				microSacs = microSacs( tarLoc(2,:) ~= 0 );
			else
				microSacs = microSacs( tarLoc(2,:) == 0 );
			end
			nGroups = 3;
			N = floor( size(microSacs,2) / nGroups );
			% microSacs = microSacs( N*0+1 : N*1 );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ task, '_Slices_', monkey, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

			t_step = 0.01;
			ang_step = 2;

			tarLoc = [microSacs.tarLoc];
			rfLoc = [microSacs.rfLoc];
			index = [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ];

			%% show raw data
			edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };
			if( strcmpi( monkey, 'abao' ) && strcmpi( task, 'cc' ) && isOblique )
				edges = { -0.22 : t_step : 0.6, -180 : ang_step : 180 };	%% for abao oblique target
			end

			%% for fitting
			pdffun = @(x, w, param1, param2, param3, param4) w * pdf( 'norm', x, param1, param2 ) + (1-w) * pdf( 'norm', x, param3, param4 );
			cdffun = @(x, w, param1, param2, param3, param4) w * cdf( 'norm', x, param1, param2 ) + (1-w) * cdf( 'norm', x, param3, param4 );
			starts = [ 0.5 edges{2}(45) 30 edges{2}(135) 30 ];
			lowerbounds = [ 0 edges{2}(1) 1 edges{2}(90) 1 ];
			upperbounds = [ 1 edges{2}(90) 180 edges{2}(180) 180 ];
			options = statset( 'display', 'off', 'MaxIter', 100000, 'MaxFunEvals', 200000, 'FunValCheck', 'off' );
			X = edges{2}(1) : ang_step : edges{2}(end);

			iSubs = zeros( 4, 25 );
			iSubs(:) = 1:100;
			iSubs = iSubs';
			iSub = 1;
			for( i = 1 : size(index,1) )
				if( strcmpi( task, 'asc' ) )
					t = [ microSacs(index(i,:)).latency ] - [ microSacs(index(i,:)).tCue ];
				elseif( strcmpi( task, 'cc' ) || strcmpi( task, 'mem' ) )
					t = [ microSacs(index(i,:)).latency ] - [ microSacs(index(i,:)).tRf ];
				end
				ang = [ microSacs(index(i,:)).angle ];
				if( ~strcmpi( monkey, 'abao' ) || ~strcmpi( task, 'cc' ) || ~isOblique )	%% not abao oblique target
					ang( ang < 0 ) = ang( ang < 0 ) + 360;
				end

				cdata = hist3( [t; ang]', 'edges', edges );

				r = 0;
				for( j = 1 : 50 )
					subplot( 2, 50, (i-1)*50 + j ); hold on;
					iSub = iSub + 1;

					t_ang = double( ang( edges{1}( 30 + max([-r+j 1]) ) < t & t < edges{1}( 30 + min([r+j+1 end]) ) ) );
					if( ~isempty(t_ang) )
						params = num2cell( mle( t_ang, 'pdf', pdffun, 'start', starts, 'lowerbound', lowerbounds, 'upperbound', upperbounds, 'optimfun', 'fmincon', 'options', options ) );
						% plot( X, ang_step * pdffun( X, params{:} ), 'r', 'LineWidth', 1 );
						view(90,-90);
					end
					
					y = sum( cdata( (30+j) : min( [30+j,end] ), : ), 1 );
					set( bar( edges{2}, y / sum(y) ), 'EdgeColor', 'none', 'FaceColor', [ 0 1 0 ] );
					set( gca, 'xtick', [], 'ytick', [], 'xlim', edges{2}([1 end]) );
				end
			end
		end

		function tStart = RotationIndex( folder, monkey, task, isOblique, ampEdges )
			if( nargin() < 3 ) disp( 'Usage: MyMethods.RotationIndex( folder, monkey, task, isOblique = false, ampEdges = [0,5] )' ); return; end
			if( nargin() == 3 ) isOblique = false; end
			if( nargin() < 4 ) ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

            tStart = MyMethods.GetTStart( monkey, task );
            if( isempty( tStart ) ) return; end

			if( strcmpi( task, 'asc' ) )
				microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );
				microSacs = MyMethods.Get1stAfter( microSacs, 'tCue', tStart );
			elseif( strcmpi( task, 'cc' ) || strcmpi(task, 'mem' ) )
            	microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > tStart );
            	microSacs = MyMethods.Get1stAfter( microSacs, 'tRf', tStart );
            end

			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );

			tarLoc = [microSacs.tarLoc];
			if( isOblique )
				microSacs = microSacs( tarLoc(2,:) ~= 0 );
			else
				microSacs = microSacs( tarLoc(2,:) == 0 );
			end
			nGroups = 3;
			N = floor( size(microSacs,2) / nGroups );
			% microSacs = microSacs( N*0+1 : N*1 );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ task, '_RotationIndex_', monkey, '_isOblique_', num2str(isOblique), '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

		 	t_step = 0.01;
			ang_step = 2;

			tarLoc = [microSacs.tarLoc];
			rfLoc = [microSacs.rfLoc];
			index = [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ];

			%% show raw data
			edges = { tStart : t_step : 0.6, 0 : ang_step : 360 };
			if( strcmpi(monkey, 'abao' ) && strcmpi(task, 'cc' ) && isOblique )
				edges = { tStart : t_step : 0.6, -180 : ang_step : 180 };	%% for abao colorcue oblique target
			end

			for( i = 1 : size(index,1) )				
				subplot( 2, 2, i );
				hold on;

				if( strcmpi(task, 'asc' ) )
					t = [ microSacs(index(i,:)).latency ] - [ microSacs(index(i,:)).tCue ];
				elseif( strcmpi(task, 'cc' ) || strcmpi(task, 'mem' ) )
					t = [ microSacs(index(i,:)).latency ] - [ microSacs(index(i,:)).tRf ];
				end
				ang = [ microSacs(index(i,:)).angle ];
				if( ~strcmpi(monkey, 'abao' ) || ~strcmpi(task, 'cc' ) || ~isOblique )	%% not abao oblique target
					ang( ang < 0 ) = ang( ang < 0 ) + 360;
				end

				cdata = hist3( [t; ang]', 'edges', edges );
				k = 2;
				colours = { 'g.', 'b.', 'r.' };
				x = zeros( k, size(edges{1},2) - 1 );
				for( j = 1 : size(edges{1},2) - 1 )
					r = 0;
					t_ang = ang( edges{1}(max([-r+j 1])) < t & t < edges{1}(min([r+j+1 end])) );
					if( isempty( t_ang ) || size(t_ang,2) < 3 ) continue; end
					[ idx, x(:,j) ] = kmeans( t_ang, k );
					[ x(:,j) ix ] = sort( x(:,j), 1 );
					for( ik = 1 : k )
						plot( ones( 1, sum(idx==ix(ik)) ) * ( edges{1}(j) + t_step/2 ), t_ang(idx==ix(ik)), colours{ik} );
					end
				end

				scatter( t, ang, 1, 'r.' );
				% plot( t, ang, '.' );
				% plot( edges{1}(1:end-1), x(1,:), 'g.' );
				% plot( edges{1}(1:end-1), x(2,:), 'y.' );
				% plot( edges{1}(1:end-1), x(3,:), 'm.' );

				[idx] = kmeans( [t;ang]', 2 );
				% plot( t(idx==1), ang(idx==1), 'b.' );
				% plot( t(idx==2), ang(idx==2), 'r.' );
			end

		 end


		function RTData = CCRankSumTest( folder, monkey, ampEdges )
			%% ranksum test for color cue task

			if( nargin() < 2 ), disp( 'Usage: MyMethods.CCRankSumTest( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			if( strcmp( monkey, 'abao' ) )
				tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
			else
				return;
			end

			index = find( [microSacs.latency] - [microSacs.tRf] > tStart );
					
			trialIndex = [microSacs(index).trialIndex];
			index = index( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );
			microSacs(index) = [];
			% microSacs = microSacs( ( strfind( [microSacs.name], '201212' ) + 5 ) / 6 );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tRf] < 0.6 );

			tarLoc = [microSacs.tarLoc];
			index = [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ] & repmat( tarLoc(2,:) == 0, 2, 1 );
			index = [ index; [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ] & repmat( tarLoc(2,:) ~= 0, 2, 1 ) ];
			index = [...
						tarLoc(1,:) < 0 & tarLoc(2,:) == 0;...
						tarLoc(1,:) < 0 & tarLoc(2,:) ~= 0;...
						tarLoc(1,:) > 0 & tarLoc(2,:) == 0;...
						tarLoc(1,:) > 0 & tarLoc(2,:) ~= 0; ];
            names = { 'left', 'oblique left', 'right', 'oblique right' };

			RTData.bin = 0.05;
			RTData.tStart = tStart;
			RTData.tEnd = 0.6;
			% nPoints = floor( ( RTData.tEnd - RTData.tStart )*1000 / ( RTData.bin*1000 ) );
			nPoints = round( ( RTData.tEnd - RTData.tStart ) * 1000 + 1 );
			%RTData.rankTestIndex =  false( size(index,1), size(microSacs,2), nPoints ) ;
			RTData.data = cell( size(index,1), nPoints );

			%% collect data
            t = [microSacs.latency] - [microSacs.tRf];
            angles = [microSacs.angle];
            sum( angles>0 & t<0 ) / sum(t<0)
			for( i = 1 : size(index,1) )
				for( j = 1 : nPoints )
					% rankTestIndex = index(i,:) & RTData.tStart + RTData.bin*(j-1) <= t & t < RTData.tStart + RTData.bin*j;
					if( j <= RTData.bin*1000/2 )
						rankTestIndex = index(i,:) & RTData.tStart <= t & t < RTData.tStart + (j-1)/1000 + RTData.bin/2;
					elseif( j > nPoints - RTData.bin*1000/2 )
						rankTestIndex = index(i,:) & RTData.tStart + (j-1)/1000 - RTData.bin/2 <= t & t < RTData.tEnd;
					else
						rankTestIndex = index(i,:) & RTData.tStart + (j-1)/1000 - RTData.bin/2 <= t & t < RTData.tStart + (j-1)/1000 + RTData.bin/2;
					end
					if( strcmp( monkey, 'abao' ) )
						rankTestIndex = rankTestIndex & ( angles < 0 & t > 0 | t < 0 );
					elseif( strcmp( monkey, 'datou' ) )
						rankTestIndex = rankTestIndex & angles > 0;
					end
					RTData.data{i,j} = angles((rankTestIndex));
					if( isempty( RTData.data{i,j} ) ) RTData.data{i,j} = single(NaN); end
				end
			end

			%% difference test using RankSum Test
            figure; hold on;
            pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
            set( gcf, 'NumberTitle', 'off', 'name', 'diff_test' );
            nLines = size(RTData.data,1);
            nPoints = size(RTData.data,2);
            EX = cellfun( @(c) nanmean(c), RTData.data );
            for( i = size(EX,1) : -1 : 1 )
            	SPEED(i,:) = gradient( EX(i,:), 0.001 );
            	for( k = 1 : 10 )
            		SPEED(i,:) = conv( SPEED(i,:), ones(1,11)/11, 'same' );
            	end
            end
            if( strcmp( monkey, 'abao' ) )	% base line for abao: population vector
            	ind = 1 : round( ( 0 - RTData.tStart ) / RTData.bin )
            	% EX(:,ind) = cellfun( @(c) cart2pol( cos((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)', sin((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)' )/pi*180, RTData.data(:,ind) );
            end
            STD = cellfun( @(c) nanstd(c), RTData.data );
            SEM = cellfun( @(c) nanstd(c) / sqrt(size(c,2)), RTData.data );
            SEM( isnan(SEM) ) = 0;
            % x = RTData.tStart + RTData.bin/2 : RTData.bin : RTData.tEnd - RTData.bin/2;
            % x = RTData.tStart + RTData.bin/2 : 0.001 : RTData.tStart + RTData.bin/2 + ( nPoints - 1 ) * 0.001;
            x = RTData.tStart : 0.001 : RTData.tEnd;
            for( i = 1 : size(EX,1) )
            	if( i <= 12 )	colour = [ 1, (i-1) / (size(index,1)+1), (i-1) / (size(index,1)+1) ];
            	else 			colour = [ (i-13) / (size(index,1)+1), (i-13) / (size(index,1)+1) , 1 ];	end
            	if( i <= 2 )	colour = [ 1, (i-1) / 3, (i-1) / 3 ];
            	else 			colour = [ (i-3) / 3, (i-3) / 3, 1 ]; end
            	ToolKit.ErrorFill( x, EX(i,:), SEM(i,:), [0 0 0], 'LineStyle', 'none', 'FaceColor', min( [ colour+0.2; 1,1,1 ] ) );
            	% fill( [ x, x(end:-1:1) ], [ EX(i,:) - SEM(i,:)/2, EX(i,end:-1:1) + SEM(i,end:-1:1)/2 ], [0 0 0], 'LineStyle', 'none', 'FaceColor', min( [ colour+0.2; 1,1,1 ] ) );%, 'FaceAlpha', 0.8 );
            	h(i) = plot( x, EX(i,:), 'LineWidth', 2, 'color', colour, 'DisplayName', names{i} );
            	% h(i) = errorbar( x, EX(i,:), SEM(i,:)/2, SEM(i,:)/2, 'color', colour, 'LineWidth', 2, 'marker', '.', 'DisplayName', names{i} );
				plot( x, SPEED(i,:), 'LineWidth', 2, 'color', colour );

            	% p{i} = ones(nPoints-1,nPoints);
            	% for( m = 1 : nPoints-1 )
            	% 	for( n = m+1 : nPoints )
            	% 		% p{i}(m,n) = ranksum( double(RTData.data{i,m}), double(RTData.data{i,n}), 'tail', 'both', 'method', 'approximate' );
            	% 		%[ ~, p{i}(m,n) ] = ttest2( double(RTData.data{i,m}), double(RTData.data{i,n}), [], [], 'unequal' );
            	% 		% p{i}(n,m) = p{i}(m,n);
            	% 	end
            	% end

            	continue;
            	% fitting            	
            	if( strcmp( monkey, 'abao' ) )
					tmpAng = angles( index(i,:) & angles < 0 & t > RTData.tStart );
					tmpT = t( index(i,:) & angles < 0 & t > RTData.tStart );
				elseif( strcmp( monkey, 'datou' ) )
					tmpAng = angles( index(i,:) & angles > 0 & t > RTData.tStart );
					tmpT = t( index(i,:) & angles > 0 & t > RTData.tStart );
				end            	
				p = polyfit( tmpT, tmpAng, 1)
				[r pval] = corrcoef( tmpT, tmpAng )
				plot( [tStart, RTData.tEnd], polyval( p, [tStart, RTData.tEnd] ), 'color', colour, 'LineWidth', 2 );
				text( 0.25, 0-25, [ 'k = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.25, 0-50, [ 'r = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
				text( 0.7, 0-50, [ 'p = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );	
            end
            plot( [0 0], get(gca,'ylim'), 'k:' );
            legend( h, 'location', 'NorthEastOutside' );
            set( gca, 'xtick', [0.1:0.1:0.6], 'xlim', [0.09 0.62] );
            xlabel( 'Time from cue on (s)', 'FontSize', 12 );
            ylabel( 'Averaged microsaccades direction with SEM (\circ)', 'FontSize', 12 );
            return;
 			
 			ang_step = 10;
            if( strcmp( monkey, 'abao' ) )
            	edges = -180 : ang_step : 0;
            elseif( strcmp( monkey, 'datou' ) )
            	edges = 0 : ang_step : 180;
            end

            y = get(gca,'ylim');
            set( gca, 'xlim', [ RTData.tStart, RTData.tEnd ], 'xtick', x, 'ylim', [y(1) y(2)+10] );
            y = get(gca,'ylim');
            for( i = 1 : 2 )
            	text( RTData.tStart + 0.015 + (i-1)*0.15, y(2)-0.02*(y(2)-y(1)), names{i}, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
            	text( RTData.tStart + 0.025 + (i-1)*0.15, y(2)-0.02*(y(2)-y(1)), ToolKit.Array2Text(p{i}), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
            end

            for( i = [1,3] )
	            p{end+1} = ones(1,nPoints)*-1;
	            for( j = 1 : nPoints )
	            	p{end}(j) = ranksum( double(RTData.data{i,j}), double(RTData.data{i+1,j}), 'tail', 'both', 'method', 'approximate' );
	            	%[ ~, p{end}(j) ] = ttest2( double(RTData.data{i,j}), double(RTData.data{i+1,j}), [], [], 'unequal' );
	            end
	            text( RTData.tStart + 0.015, y(2) - ( 0.20+(i-1)*0.025 )*( y(2)-y(1) ), [ names{i} ' vs ' names{i+1} ToolKit.Array2Text(p{end}) ], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top' );
	        end
	        return;

            RTData.EX = EX;
            RTData.STD = STD;
            RTData.p = p;            

            figure;
            for( i = 1 : nLines )
            	for( j = 1 : nPoints )
            		subplot( nLines, nPoints, (i-1)*nPoints + j );
            		[data,ax] = hist( RTData.data{i,j}, edges );
            		set( bar( ax, data/sum(data) ), 'EdgeColor', 'none', 'FaceColor', [ i / (nPoints+1), 1, i / (nPoints+1) ] );
            	end
            end

            data = cellfun( @(c) hist( c, edges ), RTData.data, 'UniformOutput', 0 );
            % data = cellfun( @(c) c/sum(c), data, 'UniformOutput', 0 );
            for( i = 1 : nLines )
            	set( figure, 'NumberTitle', 'off', 'name', names{i} );
            	bar( edges, cat( 1, data{i,:} )' );
            	title( names{i} );
            end

            for( i = [1,3] )
	            for( j = 1 : nPoints )
	            	set( figure, 'NumberTitle', 'off', 'name', [ names{i}, '&', names{i+1}, num2str(j) ] );
	            	bar( edges, cat( 1, data{i:i+1,j} )' );
	            	title( [ names{i}, '&', names{i+1}, num2str(j) ] );
	            end
	        end
		end

		function [ stats, pVal ] = CCSlopeTest( folder, monkey, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.CCSlopeTest( folder, monkey, ampEdges = [0,5], isOblique = false )' ); return; end
			if( nargin() < 3 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			% tStart = -.25;
			if( strcmp( monkey, 'abao' ) )
				tStart = 0.107 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.104 smoothed with a Gaussian)
			elseif( strcmp( monkey, 'datou' ) )
				tStart = 0.113 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.11 smoothed with a Gaussian)
			else
				return;
			end

			index = find( [microSacs.latency] - [microSacs.tRf] > tStart );
					
			trialIndex = [microSacs(index).trialIndex];
			index = index( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );
			microSacs(index) = [];
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tRf] < 0.6 );

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			% mss{2} = microSacs( tarLoc(2,:) ~= 0 );
			% mss{1} = microSacs( tarLoc(2,:) == 0 );

			latency = [microSacs.responseLat];
			% mss{2} = microSacs( latency < 0.05 );
			% mss{1} = microSacs( latency > 0.13 );

			respLoc = [microSacs.responseLoc];
			meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% mss{1} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );

			amplitude = [microSacs.responseAmp];
			meanL = mean( amplitude( respLoc(1,:) < 0 ) );
			meanR = mean( amplitude( respLoc(1,:) > 0 ) );
			mss{2} = microSacs( respLoc(1,:) < 0 & amplitude < meanL | respLoc(1,:) > 0 & amplitude < meanR );
			mss{1} = microSacs( respLoc(1,:) < 0 & amplitude > meanL | respLoc(1,:) > 0 & amplitude > meanR );

			respLoc = [microSacs.responseLoc];
			centerLX = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			centerLY = mean( respLoc( 2, respLoc(1,:) < 0 ) );
			centerRX = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			centerRY = mean( respLoc( 2, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) < 0.6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) < 0.6 );
			% mss{1} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) > 0.6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) > 0.6 );


			nGroups = [ 8 8 ];
			for( m = 2:-1:1 )
				nSacs = floor( size(mss{m},2)/nGroups(m) );	% step between two adjacent groups
				for( k = nGroups(m):-1:1 )
					tmp_mss = mss{m}( ( (k-1)*nSacs + 1 ) : k*nSacs );
					tarLoc = [tmp_mss.tarLoc];
					index = [ tarLoc(1,:) < 0; tarLoc(1,:) > 0 ];
					angles = [tmp_mss.angle];
					t = [tmp_mss.latency] - [tmp_mss.tRf];
					for( i = 2:-1:1 )
						% fitting
		            	if( strcmp( monkey, 'abao' ) )
							tmpAng = angles( index(i,:) & angles < 0 & t > tStart );
							tmpT = t( index(i,:) & angles < 0 & t > tStart );
						elseif( strcmp( monkey, 'datou' ) )
							tmpAng = angles( index(i,:) & angles > 0 & t > tStart );
							tmpT = t( index(i,:) & angles > 0 & t > tStart );
						end
						coefs = polyfit( tmpT, tmpAng, 1);
						stats(m,k,i).coefs = coefs(1);
						[ r, pval ] = corrcoef( tmpT, tmpAng );
						stats(m,k,i).r = r(2);
						stats(m,k,i).pval = pval(2);
					end
				end
			end

			data{4} = [stats(2,:,2).coefs];	% oblique right
			data{1} = [stats(1,:,1).coefs];	% horizontal left
			data{2} = [stats(2,:,1).coefs];	% oblique left
			data{3} = [stats(1,:,2).coefs];	% horizontal right

			for( i = 4 : -1 : 1 )
				EX(i) = mean(data{i});
				SEM(i)	 = std(data{i}) / sqrt( size( data{i}, 2 ) );
			end

			pVal.L_OL	= ToolKit.PermutationTest( abs(data{1}), abs(data{2}) );
			pVal.R_OR	= ToolKit.PermutationTest( data{3}, data{4} );
			pVal.L_R	= ToolKit.PermutationTest( data{1}, data{3} );
			pVal.OL_OR	= ToolKit.PermutationTest( data{2}, data{4} );

			colors = { 'r', [1,1/3,1/3], 'b', [1/3,1/3,1] };

			FONTSIZE = 24;
			figure;
			subplot(1,2,1); hold on;
			for( i = 1 : 4 )
				bar( ( sum( nGroups( mod( 0:i-2, 2 ) + 1 ) ) + 1 : sum( nGroups( mod( 0:i-1, 2 ) + 1 ) ) ) + 2*(i-1), data{i}, 0.8, 'EdgeColor', 'none', 'FaceColor', colors{i} );
			end

			subplot(1,2,2); hold on;
			for( i = 1 : 4 )
				bar( i, mean(data{i}), 0.8, 'EdgeColor', 'none', 'FaceColor', colors{i} );
				plot( [ i, i ], EX(i) + [ -SEM(i), SEM(i) ] / 2, 'LineWidth', 2, 'color', 'k' );% 'r' );
			end
			
			% show significance
			index = { [1 2], [3 4], [1 3 2], [2 4 3] };
			pVals = [ pVal.L_OL, pVal.R_OR, pVal.L_R, pVal.OL_OR ];
			hDist = [ 0.05, 0.05, 0.1, 0.15 ];
			for( i = 1 : 4 )
				for( k = size( index{i}, 2 ) : -1 : 1 )
					if( EX( index{i}(k) ) < 0 )
						y(k) = EX( index{i}(k) ) - SEM( index{i}(k) ) / 2;
					else
						y(k) = EX( index{i}(k) ) + SEM( index{i}(k) ) / 2;
					end
				end
				if( size( index{i} , 2 ) > 2 )
					if( all( y < 0 ) )
						y(1) = min(y);
					else
						y(1) = max(y);
					end
				end
				ToolKit.ShowSignificance( [ index{i}(1), y(1) ], [ index{i}(2), y(2) ], pVals(i), hDist(i), true, 'FontSize', FONTSIZE );
			end

			set( gca, 'xlim', [0 5], 'xtick', 1:4, 'xTickLabel', { 'L', 'OL', 'R', 'OR' }, 'FontSize', FONTSIZE );
			% y = get( gca, 'ylim' );
			% text( 1.5, y(2), sprintf( '%.4f', pVal.L_OL ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			% text( 3.5, y(2), sprintf( '%.4f', pVal.R_OR ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			ylabel( 'Microsaccades direction rotation speed (\circ/s)', 'FontSize', FONTSIZE );

		end

		function CCBias = CCBiasAnalyzer( folder, monkey, isOblique, ang_step, ang_win )
			if( nargin() < 3 ), isOblique = false; end
			if( nargin() < 4 ), ang_step = 10; end
			if( nargin() < 5 ), ang_win = 20; end

			if( exist( [folder,'\bias\CCBias.mat'], 'file' ) == 2 )
				load( [folder,'\bias\CCBias.mat'] );
			else
				CCBias = [];
				cc = BlocksAnalyzer( 'CCueBlock', ToolKit.ListMatFiles(folder) );
				for( iBlock = 1 : cc.nBlocks )
					CCBias(end+1).name = cc.blocks(iBlock).blockName;
					
					CCBias(end).fp2rf.angles			= [];	% angles for breaks after fixation point on before candidate targets on
					CCBias(end).fp2rf.time				= [];	% break time aligned to fp on
					CCBias(end).rf2j1.tarLeft.angles	= [];	% angles for breaks after cue on when target is on the left side
					CCBias(end).rf2j1.tarLeft.ePoints	= [];	% saccade end points
					CCBias(end).rf2j1.tarLeft.time		= [];	% break time aligned to cue on
					CCBias(end).rf2j1.tarRight.angles	= [];	% angles for breaks after cue on when target is on the right side
					CCBias(end).rf2j1.tarRight.ePoints	= [];	% saccade end points
					CCBias(end).rf2j1.tarRight.time		= [];	% break time alinged to cue on
					CCBias(end).errors.tarLeft.angles	= [];	% angles for errors when target is on the left side
					CCBias(end).errors.tarLeft.ePoints	= [];	% saccade end points
					CCBias(end).errors.tarLeft.time		= [];	% saccade time aligned to jmp1 on
					CCBias(end).errors.tarRight.angles 	= [];	% angles for errors when target i on the right side
					CCBias(end).errors.tarRight.ePoints	= [];	% saccade end points
					CCBias(end).errors.tarRight.time	= [];	% saccade time aligned to jmp1 on
					CCBias(end).nLeftBreaks		= 0;
					CCBias(end).nRightBreaks	= 0;
					CCBias(end).nLeftErrors		= 0;
					CCBias(end).nRightErrors	= 0;
					CCBias(end).nLeftCorrect	= 0;
					CCBias(end).nRightCorrect	= 0;
					
					breaks = cc.blocks(iBlock).trials( [cc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
					if( ~isempty(breaks) )
						%% for CCBias(end).fp2rf
						fp = [breaks.fp];
						rf = [breaks.rf];
						trials = breaks( [fp.tOn] > 0 & [rf.tOn] < 0 );
						if( ~isempty(trials) )
							[ tBreak, breakSacs ] = trials.GetBreak();
							fp = [trials.fp];
							% tIndex = tBreak > [fp.tOn] + 0.25;	% tmp index of breaks 250ms after fp on
							CCBias(end).fp2rf.angles = [breakSacs.angle];
							CCBias(end).fp2rf.time = tBreak - [fp.tOn];
						end

						%% for CCBias(end).rf2j1
						rf = [breaks.rf];
						jmp1 = [breaks.jmp1];
						trials = breaks( [rf.tOn] > 0 & [jmp1.tOn] < 0 );
						if( ~isempty(trials) )
							rf = [trials.rf];
							red = [rf.red];
							rfx = [rf.x];
							x = rfx( red == 255 );
							
							%% for target left condition
							[ tBreak, breakSacs ] = trials(x<0).GetBreak;
							CCBias(end).rf2j1.tarLeft.angles = [breakSacs.angle];
							ePoints = [breakSacs.termiPoints];
                            if( ~isempty(ePoints) )
                                CCBias(end).rf2j1.tarLeft.ePoints = ePoints(:,2);
                            end
							CCBias(end).rf2j1.tarLeft.time = tBreak - [ rf(x<0).tOn ];
							CCBias(end).nLeftBreaks = sum( x < 0 );

							%% for target right condition
							[ tBreak, breakSacs ] = trials( x > 0 ).GetBreak;
							CCBias(end).rf2j1.tarRight.angles = [breakSacs.angle];
							ePoints = [breakSacs.termiPoints];
                            if( ~isempty(ePoints) )
                                CCBias(end).rf2j1.tarRight.ePoints = ePoints(:,2);
                            end
							CCBias(end).rf2j1.tarRight.time = tBreak - [ rf(x>0).tOn ];
							CCBias(end).nRightBreaks = sum( x > 0 );
						end
					end

					%% for CCBias(end).errors
					trials = cc.blocks(iBlock).trials( [cc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.ERROR );
					if( ~isempty(trials) )
						jmp1 = [trials.jmp1];
						CCBias(end).nLeftErrors = sum( [jmp1.x] < 0 );
						CCBias(end).nRightErrors = sum( [jmp1.x] > 0 );
						j1win = 2.5;
						for( trial = trials )
							endPoint = trial.saccades(trial.iResponse1).termiPoints(:,2);
							% if( ~inpolygon( endPoint(1), endPoint(2), [ -j1win j1win j1win -j1win -j1win ] + trial.jmp1.x, [ -j1win -j1win j1win j1win -j1win ] + trial.jmp1.y ) )
								if( trial.jmp1.x < 0 )
									CCBias(end).errors.tarLeft.angles = trial.saccades(trial.iResponse1).angle;
									CCBias(end).errors.tarLeft.ePoints = trial.saccades(trial.iResponse1).termiPoints(:,2);
									CCBias(end).errors.tarLeft.time = trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn;
								elseif( trial.jmp1.x > 0 )
									CCBias(end).errors.tarRight.angles = trial.saccades(trial.iResponse1).angle;
									CCBias(end).errors.tarRight.ePoints = trial.saccades(trial.iResponse1).termiPoints(:,2);
									CCBias(end).errors.tarRight.time = trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn;
								end
							% end
						end
					end

					%% for correct
					trials = cc.blocks(iBlock).trials( [cc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT );
					if( ~isempty(trials) )
						jmp1 = [trials.jmp1];
						CCBias(end).nLeftCorrect = sum( [jmp1.x] < 0 );
						CCBias(end).nRightCorrect = sum( [jmp1.x] > 0 );
					end

                end
                mkdir( [folder, '\bias' ] );
				save( [folder,'\bias\CCBias.mat'], 'CCBias' );
			end

			tIndex = false(size(CCBias));	% index for bolique blocks
			for( i = 1 : size(CCBias,2) )
				if( any( CCBias(i).name == 's' ) ) tIndex(i) = true; end
			end
			if( isOblique ) CCBias(~tIndex) = [];
			else 	CCBias(tIndex) = []; end
			
			n = size(CCBias,2);
			st = 15;
			nSt = ceil( n/st );
			for( i = 1 : nSt )
				CCBias(i).name = sprintf( [ repmat( '%s|', 1, st-1 ), '%s' ], CCBias(i).name );

				fp2rf = [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).fp2rf ];
				CCBias(i).fp2rf.angles = [fp2rf.angles];
				CCBias(i).fp2rf.time = [fp2rf.time];

				rf2j1 = [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).rf2j1 ];
				tarLeft = [rf2j1.tarLeft];
				CCBias(i).rf2j1.tarLeft.angles = [tarLeft.angles];
				CCBias(i).rf2j1.tarLeft.ePoints = [tarLeft.ePoints];
				CCBias(i).rf2j1.tarLeft.time = [tarLeft.time];
				tarRight = [rf2j1.tarRight];
				CCBias(i).rf2j1.tarRight.angles = [tarRight.angles];
				CCBias(i).rf2j1.tarRight.ePoints = [tarRight.ePoints];
				CCBias(i).rf2j1.tarRight.time = [tarRight.time];

				errors = [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).errors ];
				tarLeft = [errors.tarLeft];
				CCBias(i).errors.tarLeft.angles = [tarLeft.angles];
				CCBias(i).errors.tarLeft.ePoints = [tarLeft.ePoints];
				CCBias(i).errors.tarLeft.time = [tarLeft.time];
				tarRight = [errors.tarRight];
				CCBias(i).errors.tarRight.angles = [tarRight.angles];
				CCBias(i).errors.tarRight.ePoints = [tarRight.ePoints];
				CCBias(i).errors.tarRight.time = [tarRight.time];
				CCBias(i).nLeftBreaks = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nLeftBreaks ] );
				CCBias(i).nRightBreaks = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nRightBreaks ] );
				CCBias(i).nLeftErrors = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nLeftErrors ] );
				CCBias(i).nRightErrors = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nRightErrors ] );
				CCBias(i).nLeftCorrect = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nLeftCorrect ] );
				CCBias(i).nRightCorrect = sum( [ CCBias( (i-1)*st+1 : min( [i*st,n] ) ).nRightCorrect ] );
			end
			CCBias(nSt+1:end) = [];
			
			%% fp2rf: population
			% get data
			angles = [];
			time = [];
			for( i = 1 : size(CCBias,2) )
				time = [ time, CCBias(i).fp2rf.time ];
				angles = [ angles, CCBias(i).fp2rf.angles( CCBias(i).fp2rf.time > 0.25 ) ];		% only use breaks 250ms after fixation on
			end			

			set( figure, 'NumberTitle', 'off', 'name', [ monkey,' Breaks After Fp On Before Target On ', ' (Population)' ] );

			% time distribution
			subplot(2,2,1);
			t_step = 0.01;
			[data, ax] = hist( time, min(time) - t_step/2 : t_step : max(time) + t_step/2 );
			% bar( ax, data/sum(data), 1, 'g' );
			bar( ax, data, 1, 'g' );
			xlabel( 'Break time (s)', 'FontSize', 12 );
			% ylabel( 'Proportion (%)', 'FontSize', 12 );
			ylabel( 'Number of trials', 'FontSize', 12 );
			title( 'Time distribution of break saccades before target on', 'FontSize', 12 );
			
			% direction polar plot
			subplot(2,2,2);			
			polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
			title( 'Direction distribution of break saccades before target on', 'FontSize', 12 );

			% direction hist plot
			subplot(2,2,3);
			[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Direction distribution of break saccades before target on', 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;
			bar( 1, sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2), 0.5, 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles & angles < ang_win ) / size(angles,2), 0.5, 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			%% fp2rf: significance
			tIndex = false(size(CCBias));
			for( i = size(CCBias,2) : -1 : 1 )
				tAngs = CCBias(i).fp2rf.angles( CCBias(i).fp2rf.time > 0.25 );
				if( isempty(tAngs) )
					tIndex(i) = true;
					continue;
				end
				left(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				right(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
			end
			left(tIndex) = [];
			right(tIndex) = [];

			set( figure, 'NumberTitle', 'off', 'name', [ monkey,' Breaks After Fp On Before Target On ', ' (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			plot( left, right, 'b:^' );
			plot( left(1), right(1), 'r^' );
			axis('equal');
			set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
			ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(left), 0.5, 'g' );
			errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(right), 0.5, 'r' );
			errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			if( mean(left) < mean(right) )	tail = 'left';
			else 							tail = 'right'; end
			text( 2.7, 0.9, sprintf( 'p = %f\ntail: %s', signrank( left, right, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			%% rf2j1 break ratio to all breaks: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.6;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.45;
			else
				tBound = 0.6;
			end
			for( i = 1 : size(CCBias,2) )
				time.left = [ time.left, CCBias(i).rf2j1.tarLeft.time ];
				time.right = [ time.right, CCBias(i).rf2j1.tarRight.time ];
				angles.left = [ angles.left, CCBias(i).rf2j1.tarLeft.angles( CCBias(i).rf2j1.tarLeft.time < tBound ) ];
				angles.right = [ angles.right, CCBias(i).rf2j1.tarRight.angles( CCBias(i).rf2j1.tarRight.time < tBound ) ];
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Target On (Population)' ] );
			
			% time distribution
			subplot(2,2,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			% bar( ax, data/sum(data), 1, 'g' );
			bar( ax, data, 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			% bar( ax, data/sum(data), 1, 'r' );
			bar( ax, data, 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xlim', [0 0.65] )
			xlabel( 'Break time (s)', 'FontSize', 12 );
			% ylabel( 'Proportion (%)', 'FontSize', 12 );
			ylabel( 'Number of trials', 'FontSize', 12 );
			title( 'Time distribution of break saccades after target on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,2,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of break saccades after target on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction hist plot
			subplot(2,2,3); hold on;
			[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Direction distribution of break saccades after target on', 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;
			bar( 1, sum( angles.left < -180 + ang_win | angles.left > 180 - ang_win ) / size(angles.left,2), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles.right & angles.right < ang_win ) / size(angles.right,2), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / size(angles.right,2), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum( -ang_win < angles.left & angles.left < ang_win ) / size(angles.left,2), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			title( sprintf( 'Break ratio to all breaks (Window: +-%d\\circ)', ang_win ), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% rf2j1 break ratio to all breaks: significance
			% get data
			for( i = size(CCBias,2) : -1 : 1 )
				tAngs = CCBias(i).rf2j1.tarRight.angles( CCBias(i).rf2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				tAngs = CCBias(i).rf2j1.tarLeft.angles( CCBias(i).rf2j1.tarLeft.time < tBound );
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Target On (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Break ratio to all breaks (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% rf2j1 break ratio to all trials
			% get data
			nLeftBreaks = sum( [CCBias.nLeftBreaks] );
			nLeftErrors = sum( [CCBias.nLeftErrors] );
			nLeftCorrect = sum( [CCBias.nLeftCorrect] );
			nRightBreaks = sum( [CCBias.nRightBreaks] );
			nRightErrors = sum( [CCBias.nRightErrors] );
			nRightCorrect = sum( [CCBias.nRightCorrect] );
			for( i = size(CCBias,2) : -1 : 1 )
				NLeft(i) = CCBias(i).nLeftBreaks + CCBias(i).nLeftErrors + CCBias(i).nLeftCorrect;		% number of target left trials
				NRight(i) = CCBias(i).nRightBreaks + CCBias(i).nRightErrors + CCBias(i).nRightCorrect;	% number of target right trials
				tAngs = CCBias(i).rf2j1.tarLeft.angles( CCBias(i).rf2j1.tarLeft.time < tBound );
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target left
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target left
				tAngs = CCBias(i).rf2j1.tarRight.angles( CCBias(i).rf2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target right
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target right
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Trials After Target On (Ratio)' ] );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );

			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( sprintf('Break ratio to all trials (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			% dots plot
			LL = LL./NLeft;
			RR = RR./NRight;
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,[1 2 4 5]); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Month by month break ratio (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 0.1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% errors: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			% if( strcmpi( monkey, 'abao' ) )
			% 	tBound = 0.6;
			% elseif( strcmpi( monkey, 'datou' ) )
			% 	tBound = 0.45;
			% else
			% 	tBound = 0.6;
			% end
			j1win = 2.5;
			for( i = size(CCBias,2) : -1 : 1 )
				time.left = [ time.left, CCBias(i).rf2j1.tarLeft.time( CCBias(i).rf2j1.tarLeft.time > tBound ) - 0.6, CCBias(i).errors.tarLeft.time ];
				time.right = [ time.right, CCBias(i).rf2j1.tarRight.time( CCBias(i).rf2j1.tarRight.time > tBound ) - 0.6, CCBias(i).errors.tarRight.time ];
				angles.left = [ angles.left, CCBias(i).rf2j1.tarLeft.angles( CCBias(i).rf2j1.tarLeft.time > tBound ), CCBias(i).errors.tarLeft.angles ];
				angles.right = [ angles.right, CCBias(i).rf2j1.tarRight.angles( CCBias(i).rf2j1.tarRight.time > tBound ), CCBias(i).errors.tarRight.angles ];
				
				LL(i) = CCBias(i).nLeftCorrect;
				RR(i) = CCBias(i).nRightCorrect;
				LR(i) = 0;
				RL(i) = 0;
				for( m = 1 : size( CCBias(i).rf2j1.tarLeft.ePoints, 2 ) )
					if( CCBias(i).rf2j1.tarLeft.time(m) > tBound )
						if( inpolygon( CCBias(i).rf2j1.tarLeft.ePoints(1,m), CCBias(i).rf2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LL(i) = LL(i) + 1;
						elseif( inpolygon( CCBias(i).rf2j1.tarLeft.ePoints(1,m), CCBias(i).rf2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LR(i) = LR(i) + 1;
						end
					end
				end
				for( m = 1 : size( CCBias(i).errors.tarLeft.ePoints, 2 ) )
					if( inpolygon( CCBias(i).errors.tarLeft.ePoints(1,m), CCBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LL(i) = LL(i) + 1;
					elseif( inpolygon( CCBias(i).errors.tarLeft.ePoints(1,m), CCBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LR(i) = LR(i) + 1;
					end
				end
				for( m = 1 : size( CCBias(i).rf2j1.tarRight.ePoints, 2 ) )
					if( CCBias(i).rf2j1.tarRight.time(m) > tBound )
						if( inpolygon( CCBias(i).rf2j1.tarRight.ePoints(1,m), CCBias(i).rf2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RL(i) = RL(i) + 1;
						elseif( inpolygon( CCBias(i).rf2j1.tarRight.ePoints(1,m), CCBias(i).rf2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RR(i) = RR(i) + 1;
						end
					end
				end
				for( m = 1 : size( CCBias(i).errors.tarRight.ePoints, 2 ) )
					if( inpolygon( CCBias(i).errors.tarRight.ePoints(1,m), CCBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RL(i) = RL(i) + 1;
					elseif( inpolygon( CCBias(i).errors.tarRight.ePoints(1,m), CCBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RR(i) = RR(i) + 1;
					end
				end

			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Response ratio' ] );
			
			% time distribution
			subplot(2,3,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			% bar( ax, data/sum(data), 1, 'g' );
			bar( ax, data, 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			% bar( ax, data/sum(data), 1, 'r' );
			bar( ax, data, 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			xlabel( 'Response time (s)', 'FontSize', 12 );
			% ylabel( 'Proportion (%)', 'FontSize', 12 );
			ylabel( 'Number of trials', 'FontSize', 12 );
			title( 'Time distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,3,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( 'Correct ratio & Error ratio: Population', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			LL = LL./NLeft;
			RR = RR./NRight;
			subplot(2,3,4); hold on;
			plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			axis('equal');
			ymin = min( [ LL, RR ] ) * 0.7;
			ymax = max( [ LL, RR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target left  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target right', 'FontSize', 12 );
			title( 'Month by month response ratio: LL.VS.RR', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,5); hold on;
			plot( RL, LR, 'm:s', 'DisplayName', 'LL.VS.RR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ RL, LR ] ) * 0.7;
			ymax = max( [ RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target right  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target left (%)', 'FontSize', 12 );
			title( 'Month by month response ratio: RL.VS.LR', 'FontSize', 12 );

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( 'Correct ratio & Error ratio: Significance test', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			return;
		end

		function angles = CCBreakBeforeCue( folder, monkey, ang_win, tarCon )
			if( nargin() < 3 ) ang_win = 20; end
			if( nargin() < 4 ) tarCon = 0; end	% -1: horizontal; 0: all; 1: oblique
			if( exist( [folder,'\bias\BreakBeforeCue.mat'], 'file' ) == 2 )
				load( [folder,'\bias\BreakBeforeCue.mat'] );
			else
				CC = BlocksAnalyzer( 'CCueBlock', ToolKit.ListMatFiles(folder), DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
				index = false(1,CC.nBlocks);
				for( iBlock = CC.nBlocks : -1 : 1 )
					trials = CC.blocks(iBlock).trials( [CC.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
	                if( isempty(trials) )
	                	index(iBlock) = true;
	                	continue; 
	                end
					rf = [trials.rf];
					trials = trials( [rf.tOn] < 0 );
	                if( isempty(trials) )
	                	index(iBlock) = true;
	                	continue;
	                end
	                fp = [trials.fp];
	                [ tBreak, breakSacs ] = trials.GetBreak();
	                BreakBeforeCue(iBlock).angles = [breakSacs( tBreak > [fp.tOn] + 0.25 & [fp.tOn] > 0 ).angle];
					BreakBeforeCue(iBlock).name = CC.blocks(iBlock).blockName;
					if( isempty( BreakBeforeCue(iBlock).angles ) ) index(iBlock) = true; end
				end
				BreakBeforeCue(index) = [];
				save( [folder,'\bias\BreakBeforeCue.mat'], 'BreakBeforeCue' );
			end

			index = false(size(BreakBeforeCue));	% index for oblique
			for( i = 1 : size(BreakBeforeCue,2) )
				if( any( BreakBeforeCue(i).name == 's' ) )
					index(i) = true;
				end
			end
			if( tarCon == -1 )	% horizontal
				BreakBeforeCue(index) = [];
			elseif( tarCon == 1 )
				BreakBeforeCue(~index) = [];
			end

			n = size(BreakBeforeCue,2);
			st = 10;
			nSt = ceil( n/st );
			for( i = 1 : nSt )
				BreakBeforeCue(i).angles = [ BreakBeforeCue( (i-1)*st+1 : min( [i*st,n] ) ).angles ];
			end
			BreakBeforeCue(nSt+1:end) = [];

			angles = [BreakBeforeCue.angles];
			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'BreakBeforeCue' );
			subplot(2,2,[1 3]);
			polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
			title( 'Direction distribution of break saccades before target on', 'FontSize', 12 );
			
			subplot(2,2,2);
			ang_step = 10;
			[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			h = bar( ax, data/sum(data), 1 );
			set( h, 'LineStyle', 'none', 'FaceColor', 'g' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			left = sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2);
			right = sum( -ang_win < angles & angles < ang_win ) / size(angles,2);
			subplot(2,2,4); hold on;
			bar( 1, left, 0.5, 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, right, 0.5, 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			figure;
			subplot( 1, 2, 1 ); hold on;
			data = {BreakBeforeCue.angles};
			left = cellfun( @(c) sum( c < -180 + ang_win | c > 180 - ang_win ) / size(c,2), data );
			right = cellfun( @(c) sum( c < ang_win & c > -ang_win ) / size(c,2), data );
			plot( left, right, 'k*', 'LineStyle', ':' );
			plot( left(1), right(1), 'r*' );
			axis('equal');
			set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
			plot( [0 1], [0 1], 'k:' );
			xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
			ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );

			subplot(1,2,2);
			hold on;
			bar( 1, mean(left), 0.5, 'g' );
			errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(right), 0.5, 'r' );
			errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			if( mean(left) < mean(right) )
				tail = 'left';
			else
				tail = 'right';
			end
			% text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left-right, zeros(size(left)), 'tail', tail ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			% text( 2.7, 0.9, sprintf( 'p = %f', signrank( left, right, 'tail', tail ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', tail ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
		end

		function CCBreakAfterCue( folder, monkey, ang_win, tarCon )
			if( nargin() < 3 ) ang_win = 20; end
			if( nargin() < 4 ) tarCon = 0; end	% -1: horizontal; 0: all; 1: oblique
			if( exist( [folder,'\bias\BreakAfterCue.mat'], 'file' ) == 2 )
				load( [folder,'\bias\BreakAfterCue.mat'] );
			else
				CC = BlocksAnalyzer( 'CCueBlock', ToolKit.ListMatFiles(folder), DATA_FIELD_FLAG.EVENTS + DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
				index = false(1,CC.nBlocks);
				for( iBlock = CC.nBlocks : -1 : 1 )
					trials = CC.blocks(iBlock).trials( [CC.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
	                if( isempty(trials) )
	                	index(iBlock) = true;
	                	continue;
	                end
					rf = [trials.rf];
					trials = trials( [rf.tOn] > 0 );
	                if( isempty(trials) )
	                	index(iBlock) = true;
	                	continue;
	                end
	                rf = [trials.rf];
	                red = [rf.red];
	                rfx = [rf.x];
	                x = rfx( red == 255 );
	                [ ~, breakSacs ] = trials.GetBreak();
	                BreakAfterCue(iBlock).tarLeftAngs = [breakSacs(x<0).angle];
	                BreakAfterCue(iBlock).tarRightAngs = [breakSacs(x>0).angle];
					BreakAfterCue(iBlock).name = CC.blocks(iBlock).blockName;
					if( isempty( BreakAfterCue(iBlock).tarLeftAngs ) && isempty( BreakAfterCue(iBlock).tarRightAngs ) ) index(iBlock) = true; end
				end
				BreakAfterCue(index) = [];
				save( [folder,'\bias\BreakAfterCue.mat'], 'BreakAfterCue' );
			end

			index = false(size(BreakAfterCue));	% index for oblique
			for( i = 1 : size(BreakAfterCue,2) )
				if( any( BreakAfterCue(i).name == 's' ) )
					index(i) = true;
				end
			end
			if( tarCon == -1 )	% horizontal
				BreakAfterCue(index) = [];
			elseif( tarCon == 1 )
				BreakAfterCue(~index) = [];
			end

			n = size(BreakAfterCue,2);
			st = 10;
			nSt = ceil( n/st );
			for( i = 1 : nSt )
				BreakAfterCue(i).tarLeftAngs = [ BreakAfterCue( (i-1)*st+1 : min( [i*st,n] ) ).tarLeftAngs ];
				BreakAfterCue(i).tarRightAngs = [ BreakAfterCue( (i-1)*st+1 : min( [i*st,n] ) ).tarRightAngs ];
			end
			BreakAfterCue(nSt+1:end) = [];

			n = size(BreakBeforeCue,2);
			st = 10;
			nSt = ceil( n/st );
			for( i = 1 : nSt )
				BreakBeforeCue(i).angles = [ BreakBeforeCue( (i-1)*st+1 : min( [i*st,n] ) ).angles ];
			end
			BreakBeforeCue(nSt+1:end) = [];

			leftAngs = [BreakAfterCue.tarLeftAngs];
			rightAngs = [BreakAfterCue.tarRightAngs];
			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', 'BreakAfterCue' );
			subplot(2,2,[1 3]);
			h(1) = polar( (-180:180)/180*pi, hist( leftAngs, -180:180 ), 'g' );
			hold on;
			h(2) = polar( (-180:180)/180*pi, hist( rightAngs, -180:180 ), 'r' );
			title( 'Direction distribution of break saccades after target on', 'FontSize', 12 );
			legend( h, 'Tar left', 'Tar right' );
			clear h;
			
			subplot(2,2,2);
			hold on;
			ang_step = 10;
			[data, ax] = hist( leftAngs, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 0.5, 'LineStyle', 'none', 'FaceColor', 'g' );			
			[data, ax] = hist( rightAngs, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax+ang_step/2, data/sum(data), 0.5, 'LineStyle', 'none', 'FaceColor', 'r' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			left = sum( rightAngs < -180 + ang_win | rightAngs > 180 - ang_win ) / size(rightAngs,2);
			right = sum( -ang_win < leftAngs & leftAngs < ang_win ) / size(leftAngs,2);
			subplot(2,2,4); hold on;
			h(1) = bar( 1, left, 0.5, 'g', 'DisplayName', 'Break toward left when target right' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			h(2) = bar( 2, right, 0.5, 'r', 'DisplayName', 'Break toward right when target left' );
			legend(h);
			clear h;
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
		end

		function ShowSPPopulation( folder, monkey, ampEdges )
			%% size perception

			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowSPPopulation( folder, monkey, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', monkey, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ monkey, 'MicroSacs = microSacs;' ] );
			end

			microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > -0.1 );

			trialIndex = [microSacs.trialIndex];
			index1 = [ 1, find( trialIndex(2:end) - trialIndex(1:end-1) ~= 0 ) + 1 ];		% 1st sacs
			index1 = index1( [microSacs(index1).latency] - [microSacs(index1).tRf] <= 0.05 );
			iUp_index1 = find( [microSacs(index1).angle] > 0 );		% index of up trials in index1
			iUp_index1(end) = [];
			iDown_index1 = find( [microSacs(index1).angle] < 0 );	% index of down trials in index1
			iDown_index1(end) = [];
			% index = cellfun( @(c) c(1) : ( c(2) - 1 ), num2cell( index1( [iUp_index1', iUp_index1'+1] ), 2 ), 'UniformOutput', 0 );
			index = cellfun( @(c) c(1) : ( c(2) - 1 ), num2cell( index1( [iDown_index1', iDown_index1'+1] ), 2 ), 'UniformOutput', 0 );
			% microSacs = microSacs([index{:}]);

			shape = [microSacs.shape];
			shape_diff = abs( shape(1:2:end) - shape(2:2:end) );
			% microSacs = microSacs( shape_diff == 5 | shape_diff == 6 );
			% microSacs = microSacs( shape_diff == 1 | shape_diff == 2 );
			MicroSacs = microSacs;
			for( dif = 1 : 6 )
				microSacs = MicroSacs( shape_diff == dif );
			
	            tStart = 0.07;

				index1 = find( [microSacs.latency] - [microSacs.tRf] > tStart );
				trialIndex = [microSacs(index1).trialIndex];
				index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
				index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
				trialIndex = [microSacs(index2).trialIndex];
				index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

				microSacs(index2) = [];	% 1st sacs
				% microSacs([index1,index3]) = [];	% 2nd sacs
				% microSacs = microSacs(index3);

				microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );%& [microSacs.latency] - [microSacs.tCue] > tStart );
		
				tmpMicroSacs = microSacs;
				delays = [tmpMicroSacs.tJmp1] - [tmpMicroSacs.tRf];
				
				t0 = 0.235;
				dt = 0.065;
				dt = 0.9;
				it = 0;
				for( it = 0 : 0)%8 )
					t1 = t0 + dt * it;
					t2 = t1 + dt;
					microSacs = tmpMicroSacs( t1 <= delays & delays < t2 );

					figure;
					set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', monkey, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']_delay[', num2str(t1), ',', num2str(t2), ']_diff[', num2str(dif), ']' ] );
					pause(0.1);
					jf = get(handle(gcf),'javaframe');
				 	jf.setMaximized(1);

					t_step = 0.01;
					ang_step = 2;

					tarLoc = [microSacs.tarLoc];
					rfLoc = unique( reshape( [microSacs.rfLoc], 4, [] )', 'rows' );	% each row is a set of target locations: [x1,y1,x2,y2]
					rfx = rfLoc(1:end/2,1:2:end);	% each row is the horizontal coordinates of a set of target locations: [x1,x2]
					rfy = rfLoc(1:end/2,2:2:end); % each row is the vertical coordinates of a set of target locations: [y1,y2]
					if( mod( size(rfx,1), 2 ) == 1 )
						m = floor( size(rfx,1) / 2 );
						rfx = rfx( [m,m+2], : );
						rfy = rfy( [m,m+2], : );
					else
						m = size(rfx,1) / 2;
						rfx = rfx( [m,m+1], : );
						rfy = rfy( [m,m+1], : );
					end
	                index = logical([]);
					for( i = 1 : prod( size(rfx) ) )
						index(i,:) = tarLoc(1,:) == rfx(i) & tarLoc(2,:) == rfy(i);
					end
					nRows = 2;
					nColums = size(rfx,1);

					% index = [ tarLoc(1,:) < 0 ; tarLoc(1,:) > 0 ];

					%% show raw data
					cmax = 0;
					for( i = 1 : size(index,1) )
						t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
						ang = [microSacs(index(i,:)).angle];
						% ang( ang < 0 ) = ang( ang < 0 ) + 360;
	                    if( isempty(t) ) continue; end

						subplot(nRows,nColums,i); hold on;
						% edges = { min(t) - t_step/2 : t_step : max(t) + t_step/2, -180 : ang_step : 180 };
						edges = { -0.1 : t_step : 0.6, -180 : ang_step : 180 };
						% edges = { -0.4 : t_step : 0.6, 0 : ang_step : 360 };	%% for abao horizontal target
						%hist3( [t; ang]', 'edges', edges );
						cdata = hist3( [t; ang]', 'edges', edges );
			            if( ~isempty(cdata) )
			                set( pcolor( edges{1}, edges{2}, cdata' ), 'LineStyle', 'none' );
			            end
			            pause(0.6);
			            colorbar;
			            tCMAX = caxis;
			            if( cmax < tCMAX(2) ) cmax = tCMAX(2); end

			            set( gca, 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [-180:90:180] );
			            % set( gca, 'xlim', [ edges{1}(1), edges{1}(end) ], 'ylim', [ edges{2}(1), edges{2}(end) ], 'ytick', [0:90:360] );	%% for abao horizontal target
						xlabel( [ 'Time from ', 'cue on (s)' ], 'FontSize', 12 );
						ylabel( [ 'Microsaccade direction (\circ)' ], 'FontSize', 12 );

			            % show -90, 0, 90 degrees
			            plot( [ edges{1}(1), edges{1}(end) ], [-90 -90], 'w:' );
			            plot( [ edges{1}(1), edges{1}(end) ], [0 0], 'w:' );
			            plot( [ edges{1}(1), edges{1}(end) ], [90 90], 'w:' );

			            % show tar angles
						angs = cart2pol( tarLoc(1,index(i,:)), tarLoc(2,index(i,:)) ) / pi * 180;
						y = zeros( 1, size(angs,2)*3 ) * NaN;
						y( 1 : 3 : end-2 ) = angs;
						y( 2 : 3 : end-1 ) = angs;
						x = repmat( [ edges{1}(1), edges{1}(end), NaN ], 1, size(angs,2) );
						plot( x, y, ':', 'color', [0 0.4 0] );

						% % show a center window for the angles
						% win = 10;
						% fill( [ edges{1}(1), edges{1}(end), edges{1}(end), edges{1}(1), edges{1}(1) ], [ -win, -win, win, win, -win ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.2 );

						%% time points of several events
						% rf on time
		                y = get( gca, 'ylim' );
						plot( [0 0], y, 'w:' );
						text( 0, y(2), 'target', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12 );
					
						% number of trials
						x = get(gca,'xlim');
						text( x(2), y(2), sprintf( 'nTrials: %d', size(unique([microSacs(index(i,:)).trialIndex]),2) ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );
						continue;

						%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
						%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
						nUp	  = sum( ang > 0 & t > tStart );
						nDown = sum( ang < 0 & t > tStart );
						label = [];
						ratio = 0;
						angRange = 0:180;
						if( strcmp( monkey, 'datou' ) )
							tmpIndex = ang > 0 & t > tStart;
							ratio = nUp / ( nUp + nDown );
							label = '_{up}';
						elseif( strcmp( monkey, 'abao' ) )
							tmpIndex = ang < 0 & t > tStart;
							ratio = nDown / ( nUp + nDown );
							label = '_{down}';
							angRange = -180:0;

							angRange = -180:180;
							tmpIndex = t > tStart;
							% angRange = 0:360;
						end
						
						%edges{1}(end) = 0.5;
						tmpAng = ang(tmpIndex);
						tmpT = t(tmpIndex);
						p = polyfit( tmpT, tmpAng, 1);
						[r pval] = corrcoef( tmpT, tmpAng );
						plot( [tStart, edges{1}(end)], polyval( p, [tStart, edges{1}(end)] ), 'b', 'LineWidth', 2 );
						text( 0.3, -180-20, [ 'k', label, ' = ', sprintf('%7.4f',p(1)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
						text( 0.3, -180-50, [ 'r', label, ' = ', sprintf('%7.4f',r(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );
						text( 0.55, -180-50, [ 'p', label, ' = ', sprintf('%7.4f',pval(2)) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

						%% Show the averaged curve
						cdata = hist3( [tmpT; tmpAng]', 'edges', { tStart : t_step : edges{1}(end), angRange } )';				
						plot( tStart : t_step : edges{1}(end), ( angRange * cdata ) ./ ( ones(size(angRange)) * cdata ), 'c', 'LineWidth', 1 );
						
						text( 0.55, -180-20, [ 'ratio', label, ' = ', sprintf('%7.4f',ratio) ], 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left' );

			        end
		            colormap('hot');
		            for( i = 1 : size(index,1) )
		            	subplot(nRows,nColums,i);
		            	% caxis( [ 0, cmax ] );
		            end
		        end
		    end
		end


		function MemBias = SPBiasAnalyzer( folder, monkey, ang_step, ang_win )
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 20; end

			if( exist( [folder,'\bias\MemBias.mat'], 'file' ) == 2 )
				load( [folder,'\bias\MemBias.mat'] );
			else
				diary( [folder,'\bias\diary.txt'] );
				MemBias = [];
				months = ToolKit.ListFolders( folder );
				for( iMonth = 1 : size(months,1) )
					month = ToolKit.RMEndSpaces(months(iMonth,:));
					MemBias(end+1).name = month( find( month == '\', 1, 'last' ) + 1 : end );
					
					mem = BlocksAnalyzer( 'SizePerceptBlock', ToolKit.ListMatFiles(month) );
					
					MemBias(end).fp2rf.angles	= [];	% angles for breaks after fixation point on before candidate targets on
					MemBias(end).fp2rf.time		= [];	% break time aligned to fp on
					MemBias(end).rf2j1.angles	= [];	% angles for breaks after cue on when target is on the left side
					MemBias(end).rf2j1.ePoints	= [];	% saccade end points
					MemBias(end).rf2j1.time		= [];	% break time aligned to cue on
					MemBias(end).rf2j1.tarLocs	= [];	% target location when break
					MemBias(end).errors.angles	= [];	% angles for errors when target is on the left side
					MemBias(end).errors.ePoints	= [];	% saccade end points
					MemBias(end).errors.time	= [];	% saccade time aligned to jmp1 on
					MemBias(end).errors.tarLocs = [];	% target location when error
					MemBias(end).nBreaks			= zeros(1,8);	% number of breaks for each target location
					MemBias(end).nErrors			= zeros(1,8);	% number of errors for each target location
					MemBias(end).nCorrect		= zeros(1,8);	% number of correct trials for each target location
					for( iBlock = mem.nBlocks : -1 : 1 )
						breaks = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
						if( ~isempty(breaks) )
							%% for MemBias(end).fp2rf
							fp = [breaks.fp];
							rf = [breaks.rf];
							trials = breaks( [fp.tOn] > 0 & [rf.tOn] < 0 );
							if( ~isempty(trials) )
								[ tBreak, breakSacs ] = trials.GetBreak();
								fp = [trials.fp];
								% tIndex = tBreak > [fp.tOn] + 0.25;	% tmp index of breaks 250ms after fp on
								MemBias(end).fp2rf.angles = [ MemBias(end).fp2rf.angles, [breakSacs.angle] ];
								MemBias(end).fp2rf.time = [ MemBias(end).fp2rf.time, tBreak - [fp.tOn] ];
							end

							%% for MemBias(end).rf2j1
							rf = [breaks.rf];
							jmp1 = [breaks.jmp1];
							trials = breaks( [rf.tOn] > 0 & [jmp1.tOn] < 0 );
							if( ~isempty(trials) )
								rf = [trials.rf];
								
								[ tBreak, breakSacs ] = trials.GetBreak;
								MemBias(end).rf2j1.angles = [ MemBias(end).rf2j1.angles, breakSacs.angle ];
								MemBias(end).rf2j1.time = [ MemBias(end).rf2j1.time, tBreak - [rf.tOn] ];
								MemBias(end).rf2j1.tarLocs = [ MemBias(end).rf2j1.tarLocs, [ rf.x; rf.y ] ];
								ePoints = [breakSacs.termiPoints];
								if( ~isempty(ePoints) )
									MemBias(end).rf2j1.ePoints = [ MemBias(end).rf2j1.ePoints, ePoints(:,2) ];
								end

								x = [rf.x];
								y = [rf.y];
								tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
								for( i = 1 : 8 )
									MemBias(end).nBreaks(i) = MemBias(end).nBreaks(i) + sum(tIndex(i,:));
								end
							end
						end

						%% for MemBias(end).errors
						trials = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.ERROR );
						if( ~isempty(trials) )
							jmp1 = [trials.jmp1];
							x = [jmp1.x];
							y = [jmp1.y];
							tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
							for( i = 1 : 8 )
								MemBias(end).nErrors(i) = MemBias(end).nErrors(i) + sum(tIndex(i,:));
							end
							j1win = 2.5;
							for( trial = trials )
								endPoint = trial.saccades(trial.iResponse1).termiPoints(:,2);
								% if( ~inpolygon( endPoint(1), endPoint(2), [ -j1win j1win j1win -j1win -j1win ] + trial.jmp1.x, [ -j1win -j1win j1win j1win -j1win ] + trial.jmp1.y ) )
									MemBias(end).errors.angles = [ MemBias(end).errors.angles, trial.saccades(trial.iResponse1).angle ];
									MemBias(end).errors.ePoints = [ MemBias(end).errors.ePoints, trial.saccades(trial.iResponse1).termiPoints(:,2) ];
									MemBias(end).errors.time = [ MemBias(end).errors.time, trial.saccades(trial.iResponse1).latency - trial.jmp1.tOn ];
									MemBias(end).errors.tarLocs = [ MemBias(end).errors.tarLocs, [jmp1.x;jmp1.y] ];										
								% end
							end
						end

						%% for correct
						trials = mem.blocks(iBlock).trials( [mem.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.CORRECT );
						if( ~isempty(trials) )
							jmp1 = [trials.jmp1];
							x = [jmp1.x];
							y = [jmp1.y];
							tIndex = [ x>0 & y==0; x>0 & y>0; x==0 & y>0; x<0 & y>0; x<0 & y==0; x<0 & y<0; x==0 & y<0; x>0 & y<0 ];
							for( i = 1 : 8 )
								MemBias(end).nCorrect(i) = MemBias(end).nCorrect(i) + sum(tIndex(i,:));
							end
						end
					end
					% if( MemBias(end).nLeftCorrect == 0 && MemBias(end).nRightCorrect == 0 ) MemBias(end) = []; end

				end
                diary off;
                mkdir( [folder,'\bias'] );
				save( [folder,'\bias\MemBias.mat'], 'MemBias' );
			end

			%% fp2rf
			%% get data
			% for population
			angles = [];
			time = [];
			for( i = 1 : size(MemBias,2) )
				time = [ time, MemBias(i).fp2rf.time ];
				angles = [ angles, MemBias(i).fp2rf.angles( MemBias(i).fp2rf.time > 0.25 ) ];		% only use breaks 250ms after fixation on
			end

			% for significance
			tIndex = false(size(MemBias));
			for( i = size(MemBias,2) : -1 : 1 )
				tAngs = MemBias(i).fp2rf.angles( MemBias(i).fp2rf.time > 0.25 );
				if( isempty(tAngs) )
					tIndex(i) = true;
                    left(i) = NaN;
                    right(i) = NaN;
					continue;
				end
				left(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				right(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
			end
			left(tIndex) = [];
			right(tIndex) = [];

			%% names, labels...
			figName = [ monkey,' Breaks After Fp On Before Candidates On' ];
			figDirectTitle = 'Direction distribution of break saccades before candidates on';
			figTimeTitle = 'Time distribution of break saccades before candidates on';
			

			%% figure for population
			set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Population)' ] );

			% time distribution
			subplot(2,2,1);
			t_step = 0.01;
			[data, ax] = hist( time, min(time) - t_step/2 : t_step : max(time) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			xlabel( 'Break time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( figTimeTitle, 'FontSize', 12 );
			
			% direction polar plot
			subplot(2,2,2);			
			polar( (-180:180)/180*pi, hist( angles, -180:180 ), 'g' );
			title( figDirectTitle, 'FontSize', 12 );

			% direction hist plot
			subplot(2,2,3);
			[data, ax] = hist( angles, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( figDirectTitle, 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;
			bar( 1, sum( angles < -180 + ang_win | angles > 180 - ang_win ) / size(angles,2), 0.5, 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles & angles < ang_win ) / size(angles,2), 0.5, 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			%% figure for significance
			set( figure, 'NumberTitle', 'off', 'name', [ figName, ' (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			plot( left, right, 'k:*' );
			plot( left(1), right(1), 'r*' );
			axis('equal');
			set( gca, 'xlim', [0 max([left,right])*1.1], 'ylim', [0 max([left,right])*1.1] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Proportion of breaks towards left (%)', 'FontSize', 12 );
			ylabel( 'Proportion of breaks towards right (%)', 'FontSize', 12 );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(left), 0.5, 'g' );
			errorbar( 1, mean(left), std(left), std(left), 'color', 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(right), 0.5, 'r' );
			errorbar( 2, mean(right), std(right), std(right), 'color', 'r' );
			text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
			if( mean(left) < mean(right) )	tail = 'left';
			else 							tail = 'right'; end
			text( 2.7, 0.9, sprintf( 'p = %f\ntail: %s', signrank( left, right, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf( 'Window: +-%d\\circ', ang_win ), 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );

			return;

			%% cue2j1 break ratio to all breaks: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			for( i = 1 : size(MemBias,2) )
				time.left = [ time.left, MemBias(i).cue2j1.tarLeft.time ];
				time.right = [ time.right, MemBias(i).cue2j1.tarRight.time ];
				angles.left = [ angles.left, MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound ) ];
				angles.right = [ angles.right, MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound ) ];
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Population)' ] );
			
			% time distribution
			subplot(2,2,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xlim', [0 0.65] )
			xlabel( 'Break time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Time distribution of break saccades after cue on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,2,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction hist plot
			subplot(2,2,3); hold on;
			[data, ax] = hist( angles.left, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( angles.right, -180 - ang_step/2 : ang_step : 180 + ang_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			set( gca, 'xtick', [-180:45:180], 'xlim', [ -180 - ang_step/2, 180 + ang_step/2 ] );
			xlabel( 'Break direction (\circ)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Direction distribution of break saccades after cue on', 'FontSize', 12 );

			% bar comparison
			subplot(2,2,4); hold on;			
			bar( 1, sum( angles.left < -180 + ang_win | angles.left > 180 - ang_win ) / size(angles.left,2), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum( -ang_win < angles.right & angles.right < ang_win ) / size(angles.right,2), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum( angles.right < -180 + ang_win | angles.right > 180 - ang_win ) / size(angles.right,2), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum( -ang_win < angles.left & angles.left < ang_win ) / size(angles.left,2), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			title( sprintf( 'Break ratio to all breaks (Window: +-%d\\circ)', ang_win ), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% cue2j1 break ratio to all breaks: significance
			% get data
			for( i = size(MemBias,2) : -1 : 1 )
				tAngs = MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				tAngs = MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound );
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win ) / size(tAngs,2);
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win ) / size(tAngs,2);
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Breaks After Cue On (Significance)' ] );

			% dots plot
			subplot(1,2,1); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Break ratio to all breaks (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(1,2,2);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% cue2j1 break ratio to all trials
			% get data
			nLeftBreaks = sum( [MemBias.nLeftBreaks] );
			nLeftErrors = sum( [MemBias.nLeftErrors] );
			nLeftCorrect = sum( [MemBias.nLeftCorrect] );
			nRightBreaks = sum( [MemBias.nRightBreaks] );
			nRightErrors = sum( [MemBias.nRightErrors] );
			nRightCorrect = sum( [MemBias.nRightCorrect] );
			for( i = size(MemBias,2) : -1 : 1 )
				NLeft(i) = MemBias(i).nLeftBreaks + MemBias(i).nLeftErrors + MemBias(i).nLeftCorrect;		% number of target left trials
				NRight(i) = MemBias(i).nRightBreaks + MemBias(i).nRightErrors + MemBias(i).nRightCorrect;	% number of target right trials
				tAngs = MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time < tBound );
				LL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target left
				LR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target left
				tAngs = MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time < tBound );
				RL(i) = sum( tAngs < -180 + ang_win | tAngs > 180 - ang_win );			% number of leftward breaks when target right
				RR(i) = sum( -ang_win < tAngs & tAngs < ang_win );						% number of rightward breaks when target right
			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Break Ratio to All Trials After Cue On (Ratio)' ] );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );

			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( sprintf('Break ratio to all trials (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			% dots plot
			LL = LL./NLeft;
			RR = RR./NRight;
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,[1 2 4 5]); hold on;
			h(1) = plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			h(2) = plot( RL, LR, 'm:s', 'DisplayName', 'RL.VS.LR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ LL, RR, RL, LR ] ) * 0.7;
			ymax = max( [ LL, RR, RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );

			xlabel( 'Leftward break ratio: LL & RL  (%)', 'FontSize', 12 );
			ylabel( 'Rightward break ratio: RR & LR (%)', 'FontSize', 12 );
			title( sprintf('Month by month break ratio (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			legend(h);

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 0.1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( sprintf('Significance test (Window +-%d\\circ)',ang_win), 'FontSize', 12 );
			ylabel( 'Break ratio (%)', 'FontSize', 12 );

			%% errors: population
			% get data
			clear time angles;
			time.left = [];
			time.right = [];
			angles.left = [];
			angles.right = [];
			if( strcmpi( monkey, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( monkey, 'datou' ) )
				tBound = 0.4;
			else
				tBound = 0.6;
			end
			j1win = 2.5;
			for( i = size(MemBias,2) : -1 : 1 )
				time.left = [ time.left, MemBias(i).cue2j1.tarLeft.time( MemBias(i).cue2j1.tarLeft.time > tBound ) - 0.6, MemBias(i).errors.tarLeft.time ];
				time.right = [ time.right, MemBias(i).cue2j1.tarRight.time( MemBias(i).cue2j1.tarRight.time > tBound ) - 0.6, MemBias(i).errors.tarRight.time ];
				angles.left = [ angles.left, MemBias(i).cue2j1.tarLeft.angles( MemBias(i).cue2j1.tarLeft.time > tBound ), MemBias(i).errors.tarLeft.angles ];
				angles.right = [ angles.right, MemBias(i).cue2j1.tarRight.angles( MemBias(i).cue2j1.tarRight.time > tBound ), MemBias(i).errors.tarRight.angles ];
				
				LL(i) = MemBias(i).nLeftCorrect;
				RR(i) = MemBias(i).nRightCorrect;
				LR(i) = 0;
				RL(i) = 0;
				for( m = 1 : size( MemBias(i).cue2j1.tarLeft.ePoints, 2 ) )
					if( MemBias(i).cue2j1.tarLeft.time(m) > tBound )
						if( inpolygon( MemBias(i).cue2j1.tarLeft.ePoints(1,m), MemBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LL(i) = LL(i) + 1;
						elseif( inpolygon( MemBias(i).cue2j1.tarLeft.ePoints(1,m), MemBias(i).cue2j1.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							LR(i) = LR(i) + 1;
						end
					end
				end
				for( m = 1 : size( MemBias(i).errors.tarLeft.ePoints, 2 ) )
					if( inpolygon( MemBias(i).errors.tarLeft.ePoints(1,m), MemBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LL(i) = LL(i) + 1;
					elseif( inpolygon( MemBias(i).errors.tarLeft.ePoints(1,m), MemBias(i).errors.tarLeft.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						LR(i) = LR(i) + 1;
					end
				end
				for( m = 1 : size( MemBias(i).cue2j1.tarRight.ePoints, 2 ) )
					if( MemBias(i).cue2j1.tarRight.time(m) > tBound )
						if( inpolygon( MemBias(i).cue2j1.tarRight.ePoints(1,m), MemBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RL(i) = RL(i) + 1;
						elseif( inpolygon( MemBias(i).cue2j1.tarRight.ePoints(1,m), MemBias(i).cue2j1.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
							RR(i) = RR(i) + 1;
						end
					end
				end
				for( m = 1 : size( MemBias(i).errors.tarRight.ePoints, 2 ) )
					if( inpolygon( MemBias(i).errors.tarRight.ePoints(1,m), MemBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] - 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RL(i) = RL(i) + 1;
					elseif( inpolygon( MemBias(i).errors.tarRight.ePoints(1,m), MemBias(i).errors.tarRight.ePoints(2,m), [ -j1win j1win j1win -j1win -j1win ] + 10, [ -j1win -j1win j1win j1win -j1win ] ) )
						RR(i) = RR(i) + 1;
					end
				end

			end

			set( figure, 'NumberTitle', 'off', 'name', [ monkey, ' Error ratio' ] );
			
			% time distribution
			subplot(2,3,1); hold on;
			t_step = 0.01;
			[data, ax] = hist( time.left, min(time.left) - t_step/2 : t_step : max(time.left) + t_step/2 );
			bar( ax, data/sum(data), 1, 'g' );
			[data, ax] = hist( time.right, min(time.right) - t_step/2 : t_step : max(time.right) + t_step/2 );
			bar( ax, data/sum(data), 1, 'r' );
			set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
			xlabel( 'Response time (s)', 'FontSize', 12 );
			ylabel( 'Proportion (%)', 'FontSize', 12 );
			title( 'Time distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% direction polar plot
			subplot(2,3,2);
			polar( (-180:180)/180*pi, hist( angles.left, -180:180 ), 'g' );
			hold on;
			polar( (-180:180)/180*pi, hist( angles.right, -180:180 ), 'r' );
			title( 'Direction distribution of predictive saccades and errors', 'FontSize', 12 );
			legend( 'Tar left', 'Tar right' );

			% population
			subplot(2,3,3); hold on;
			bar( 1, sum(LL)/sum(NLeft), 0.5, 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, sum(RR)/sum(NRight), 0.5, 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 3, sum(RL)/sum(NRight), 0.5, 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, sum(LR)/sum(NLeft), 0.5, 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			set( gca, 'xtick', [], 'xlim', [0 5] );
			title( 'Correct ratio & Error ratio: Population', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			LL = LL./NLeft;
			RR = RR./NRight;
			subplot(2,3,4); hold on;
			plot( LL, RR, 'b:^', 'DisplayName', 'LL.VS.RR' );
			plot( LL(1), RR(1), 'r^' );
			axis('equal');
			ymin = min( [ LL, RR ] ) * 0.7;
			ymax = max( [ LL, RR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target left  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target right', 'FontSize', 12 );
			title( 'Month by month response ratio: LL.VS.RR', 'FontSize', 12 );

			% dots plot: LL.VS.RR
			RL = RL./NRight;
			LR = LR./NLeft;
			subplot(2,3,5); hold on;
			plot( RL, LR, 'm:s', 'DisplayName', 'LL.VS.RR' );
			plot( RL(1), LR(1), 'rs' );
			axis('equal');
			ymin = min( [ RL, LR ] ) * 0.7;
			ymax = max( [ RL, LR ] ) * 1.1;
			set( gca, 'xlim', [ymin ymax], 'ylim', [ymin ymax] );
			x = get(gca,'xlim');
			y = get(gca,'ylim');
			plot( [0 min([x(2)],y(2))], [0 min([x(2),y(2)])], 'k:' );
			xlabel( 'Leftward response ratio when target right  (%)', 'FontSize', 12 );
			ylabel( 'Rightward response ratio when target left (%)', 'FontSize', 12 );
			title( 'Month by month response ratio: RL.VS.LR', 'FontSize', 12 );

			% significance test
			subplot(2,3,6);	hold on;
			bar( 1, mean(LL), 0.5, 'g' );
			errorbar( 1, mean(LL), std(LL), std(LL), 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR), std(RR), 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL), std(RL), 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR), std(LR), 'color', 'r' );
			text( 4, 0, 'LR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			set( gca, 'xtick', [], 'xlim', [0 5], 'ylim', [0 1] );
			y = get( gca, 'ylim' );
			if( mean(LL) < mean(RR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 2, y(2), sprintf( 'p = %f\ntail: %s', signrank( LL, RR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			if( mean(RL) < mean(LR) )	tail = 'left';
			else 						tail = 'right'; end
			text( 4, y(2), sprintf( 'p = %f\ntail: %s', signrank( RL, LR, 'tail', tail ), tail ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
			title( 'Correct ratio & Error ratio: Significance test', 'FontSize', 12 );
			ylabel( 'Correct ratio(LL,RR), Error ratio(RL,LR) (%)', 'FontSize', 12 );

			return;
		end


		function ShowParadigm( monkey, folder )
			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];
			figure;
			
			r = 1;
			for( i = 1 : 6 )
				subplot(2,3,i);
				axis('equal');	% set the axies to the same scale
				hold on;
				set( gca, 'xlim', [-15,15], 'ylim', [-15,15], 'xtick', [], 'ytick', [], 'color', 'k' );	% set current axis

				if( any( i == [1,2,3,4,5] ) )	% fixation point
					plot( [-r r], [0 0], 'r', 'LineWidth', 2*r );
					plot( [0 0], [-r r], 'r', 'LineWidth', 2*r );
				end
				if( any( i == [2,3,4,5,6] ) )	% candidates
					rectangle( 'position', [ -r+10, -r, 2*r, 2*r ], 'FaceColor', 'r', 'Curvature', [1 1] );
					rectangle( 'position', [ -r-10, -r, 2*r, 2*r ], 'FaceColor', 'r', 'Curvature', [1 1] );
				end
				if( any( i == [3,4] ) )	% cues
					for( loc = cueLocs( : , (1:12) + 12*mod(i,3) ) )
						rectangle( 'position', [ -r+loc(1), -r+loc(2), 2*r, 2*r ], 'EdgeColor', [0 1 0], 'LineStyle', ':', 'Curvature', [1 1] );
					end
					rectangle( 'position', [ -r+cueLocs( 1, 11 + 4*mod(i,3) ), -r+cueLocs( 2, 11 + 4*mod(i,3) ), 2*r, 2*r ], 'FaceColor', [0 1 0], 'Curvature', [1 1] );
				end
			end

			if( nargin() == 2 )
				figure; hold on;
				axis('equal');
				set( gca, 'xlim', [-17 17], 'ylim', [-17 17], 'color', 'k' );
				eval( [ 'global ', monkey, 'MicroSacs;' ] );
				eval( [ 'microSacs = ', monkey, 'MicroSacs;' ] );
				if( isempty(microSacs) )
					microSacs = MyMethods.LoadMicroSacs( folder );
					eval( [ monkey, 'MicroSacs = microSacs;' ] );
				end
				cueLoc = [microSacs.cueLoc];
				uniCueLoc = double( unique( cueLoc', 'rows' )' )
				tarLoc = [microSacs.tarLoc];
				uniTarLoc = double( unique( tarLoc', 'rows' )' )

				r = 0.25;
				r = 0.5;

				for( loc = cueLocs )
					rectangle( 'position', [ -r+loc(1), -r+loc(2), 2*r, 2*r ], 'EdgeColor', [0 1 0], 'LineStyle', '-', 'Curvature', [1 1] );
					uniCueLoc( :, uniCueLoc(1,:) == loc(1) & uniCueLoc(2,:) == loc(2) ) = [];
				end

				name = [];
				for( loc =  uniCueLoc )
					rectangle( 'position', [ -r+loc(1), -r+loc(2), 2*r, 2*r ], 'EdgeColor', [0 1 0], 'LineStyle', ':', 'Curvature', [1 1] );
					% text( loc(1)+r, loc(2), sprintf( '%d', sum( cueLoc(1,:) == loc(1) & cueLoc(2,:) == loc(2) ) ), 'color', 'w' );
					name = [ name; cat( 1, microSacs( cueLoc(1,:) == loc(1) & cueLoc(2,:) == loc(2) ).name ) ];
				end

				r = 0.5;
				for( loc = uniTarLoc )
					rectangle( 'position', [ -r+loc(1), -r+loc(2), 2*r, 2*r ], 'FaceColor', 'none', 'EdgeColor', [1 0 0], 'LineStyle', '-', 'Curvature', [1 1] );
				end
				rectangle( 'position', [ -r-10, -r, 2*r, 2*r ], 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0], 'Curvature', [1 1] );
				rectangle( 'position', [ -r+10, -r, 2*r, 2*r ], 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0], 'Curvature', [1 1] );

				unique( name, 'rows' )
			end

		end

		function ColorCueEyeTraceCheck( hFig, evnt )
			%% check abao's eyetrace in color cue task
			global abaoCCBlocks;
			global iTrialsIndex;
			if( isempty(abaoCCBlocks) )
				abaoCCBlocks = BlocksAnalyzer( 'RexBlock', ToolKit.ListMatFiles('D:\data\cue_task_refinedmat\abao\colorcue'), 1+4+8+16 );
			end

			if( nargin() == 0 )
				figure( 'NumberTitle', 'off', 'name', 'Num: 1', 'KeyPressFcn', @MyMethods.ColorCueEyeTraceCheck );
				pause(0.1);
				jf = get(handle(gcf),'javaframe');
				jf.setMaximized(1);
                
                global iTrialsIndex;
				iTrialsIndex = [];
				for( iBlock = 1 : abaoCCBlocks.nBlocks )
					trials = abaoCCBlocks.blocks(iBlock).trials( [ abaoCCBlocks.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT &...
					[ 1, [abaoCCBlocks.blocks(iBlock).trials(1:end-1).type] == TRIAL_TYPE_DEF.CORRECT ] );
					for( j = 1 : size(trials,2) )
						for( k = 1 : size(trials(j).saccades,2) )
							if( -42 < trials(j).saccades(k).angle && trials(j).saccades(k).angle < -38 )
								iTrialsIndex = [ iTrialsIndex, [ iBlock; trials(j).trialIndex-1; k ] ];
							end
						end
					end
				end
				assignin( 'base', 'iTrialsIndex', iTrialsIndex );

				abaoCCBlocks.blocks(iTrialsIndex(1,1)).trials(iTrialsIndex(2,1)).PlotEyeTrace(0);
				hold on;
				plot( [1 1] * abaoCCBlocks.blocks(iTrialsIndex(1,1)).trials(iTrialsIndex(2,1)).saccades(iTrialsIndex(3,1)).latency, get(gca,'ylim'), 'r--', 'LineWidth', 2 );
				set( gcf, 'name', sprintf( 'Num: 1, iBlock:%3d, iTrial: %4d, iSaccades: %d', iTrialsIndex(1,1), iTrialsIndex(2,1), iTrialsIndex(3,1) ) );

				return;
			end

			iTrial = sscanf( get( hFig, 'name' ), '%s%d' );
			switch evnt.Key
				case 'leftarrow'					
					iTrial = iTrial(5) - 1;
				case 'downarrow'
					iTrial = iTrial(5) - 100;
				case { 'hyphen', 'subtract' }
					iTrial = iTrial(5) - 1000;
				case 'rightarrow'
					iTrial = iTrial(5) + 1;
				case 'uparrow'
					iTrial = iTrial(5) + 100;
				case { 'equal', 'add' }
					iTrial = iTrial(5) + 1000;
				case 'return'
					iTrial = sscanf( input('iTrial: ','s'), '%d' );
				otherwise
					return;
			end
			if( iTrial < 1 ) iTrial = 1; end
			if( iTrial > size(iTrialsIndex,2) ) iTrial = size(iTrialsIndex,2); end

			cla;
			abaoCCBlocks.blocks(iTrialsIndex(1,iTrial)).trials(iTrialsIndex(2,iTrial)).PlotEyeTrace(0);
			hold on;
			plot( [1 1] * abaoCCBlocks.blocks(iTrialsIndex(1,iTrial)).trials(iTrialsIndex(2,iTrial)).saccades(iTrialsIndex(3,iTrial)).latency, get(gca,'ylim'), 'r--', 'LineWidth', 2 );
			set( hFig, 'name', sprintf( 'Num: %d, iBlock:%3d, iTrial: %4d, iSaccades: %d', iTrial, iTrialsIndex(1,iTrial), iTrialsIndex(2,iTrial), iTrialsIndex(3,iTrial) ) );
		end

		function CheckEyeTrace( rb, suspicion )
			figure( 'NumberTitle', 'off', 'tag', '1', 'name', sprintf( 'i: 1', 1 ), 'KeyPressFcn', @checkEyeTrace );
			rb.blocks(suspicion(1,1)).trials(suspicion(2,1)).PlotEyeTrace(0);

			function checkEyeTrace( hFig, evnt )
				i = sscanf( get( hFig, 'tag' ), '%d' );
				switch evnt.Key
					case 'leftarrow'					
						i = i - 1;
					case 'downarrow'
						i = i - 100;
					case { 'hyphen', 'subtract' }
						i = i - 1000;
					case 'rightarrow'
						i = i + 1;
					case 'uparrow'
						i = i + 100;
					case { 'equal', 'add' }
						i = i + 1000;
					case 'return'
						tmp = sscanf( input('i: ','s'), '%d' );
                        if( ~isempty(tmp) ) i = tmp; end
					otherwise
						return;
				end
				if( i < 1 ) i = 1; end
				if( i > size(suspicion,2) ) i = size(suspicion,2); end

				set( gcf, 'tag', num2str(i), 'name', sprintf( 'i: %d', i ) );

				cla;
				rb.blocks(suspicion(1,i)).trials(suspicion(2,i)).PlotEyeTrace(0);
			end
		end

		function MainSeqDensity( data, isExtract )
			if( nargin() == 1 )
				isExtract = false;
			end

			if( isExtract )				
				subfolders = ToolKit.ListFolders(data);
				% subfolders = data;

				fixational.amplitude = [];
				fixational.peakSpeed = [];
				cFixational = 0;
				response.amplitude = [];
				response.peakSpeed = [];
				cResponse = 0;
				breaks.amplitude = [];
				breaks.peakSpeed = [];
				cBreaks = 0;
				for( i = 1 : size( subfolders, 1 ) )
					ba = BlocksAnalyzer( 'RexBlock', ToolKit.ListMatFiles( ToolKit.RMEndSpaces( subfolders(i,:) ) ) );%, DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
					fixational.amplitude( end + ba.nTrials * 4 ) = 0;
					fixational.peakSpeed( end + ba.nTrials * 4 ) = 0;
					response.amplitude( end + ba.nTrials ) = 0;
					response.peakSpeed( end + ba.nTrials ) = 0;
					breaks.amplitude( end + ba.nFixbreak ) = 0;
					breaks.peakSpeed( end + ba.nFixbreak ) = 0;
					for( iBlock = 1 : ba.nBlocks )
						for( iTrial = 1 : ba.blocks(iBlock).nTrials )
							trial = ba.blocks(iBlock).trials(iTrial);
							if( ( trial.type == TRIAL_TYPE_DEF.CORRECT || trial.type == TRIAL_TYPE_DEF.ERROR ) && size(trial.fp,2) == 1 && ~isempty(trial.iResponse1) )
								if( trial.iResponse1 - 1 )
									index = find( [ trial.saccades( 1 : trial.iResponse1-1 ).latency ] - trial.fp.tOn > 0 );
									fixational.amplitude( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).amplitude ];
									fixational.peakSpeed( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).peakSpeed ];
									cFixational = cFixational + size(index,2);
								end
								cResponse = cResponse + 1;
								response.amplitude( cResponse ) = trial.saccades(trial.iResponse1).amplitude;
								response.peakSpeed( cResponse ) = trial.saccades(trial.iResponse1).peakSpeed;
							elseif( trial.type == TRIAL_TYPE_DEF.FIXBREAK && size(trial.fp,2) == 1 && trial.fp.tOn > 0 )
								[ tBreak, breakSac ] = trial.GetBreak();
								if( tBreak < 0 || isempty(breakSac.latency) ) continue; end
								index = find( [ trial.saccades.latency ] < breakSac.latency & [trial.saccades.latency] > trial.fp.tOn );
								if( ~isempty(index) )
									fixational.amplitude( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).amplitude ];
									fixational.peakSpeed( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).peakSpeed ];
									cFixational = cFixational + size(index,2);
								end
								cBreaks = cBreaks + 1;
								breaks.amplitude( cBreaks ) = breakSac.amplitude;
								breaks.peakSpeed( cBreaks ) = breakSac.peakSpeed;
							end
						end
					end
					fixational.amplitude( cFixational+1 : end ) = [];
					fixational.peakSpeed( cFixational+1 : end ) = [];
					response.amplitude( cResponse+1 : end ) = [];
					response.peakSpeed( cResponse+1 : end ) = [];
					breaks.amplitude( cBreaks+1 : end ) = [];
					breaks.peakSpeed( cBreaks+1 : end ) = [];
				end
				mainSequence.fixational = fixational;
				mainSequence.response = response;
				mainSequence.breaks = breaks;
				save( [ data( 1 : find( data == '\' | data == '/', 1, 'last' ) ), '\mainSequence.mat' ], 'mainSequence' );
				% save( [ data( 1 : find( data == '\' | data == '/', 1, 'last' ) ), '\saccades.mat' ], 'saccades' );
			elseif( ~isstruct(data) )
				load( [ data, '\mainSequence.mat' ] );
			else
				mainSequence = data;
			end

			% return;

			% mainSequence = mainSequence( ( abs([mainSequence.angle])<45 & abs([mainSequence.angle])>0 ) & [mainSequence.amplitude] < 15 );
			% mainSequence.peakSpeed = mainSequence.peakSpeed( [mainSequence.amplitude] < 5 );
			% mainSequence.amplitude = mainSequence.amplitude( [mainSequence.amplitude] < 5 );


			min_amp = -0.7;
			max_amp = 1.3;
			min_vel = 1;
			max_vel = 3.0;
			step = 0.01;
			size_x = ( max_amp - min_amp ) / step;
			size_y = ( max_vel - min_vel ) / step;

			edge = cell(1,2);
			edge{2} = min_amp : step : max_amp;
			edge{1} = min_vel : step : max_vel;
			
			fixational = hist3( [ log10([mainSequence.fixational.peakSpeed]); log10([mainSequence.fixational.amplitude] ) ]', 'edges', edge);
				% fixational: x along the 1st dimension of the array; y along the 2nd dimension
			response = hist3( [ log10([mainSequence.response.peakSpeed]); log10([mainSequence.response.amplitude] ) ]', 'edges', edge);
			breaks = hist3( [ log10([mainSequence.breaks.peakSpeed]); log10([mainSequence.breaks.amplitude] ) ]', 'edges', edge);
			figure;
			% set( pcolor( edge{1}, edge{2}, data' ), 'LineStyle', 'none' );	% data' matches a rectangular coordinate
			% colormap('hot');
			fixational = fixational/max(max(fixational));
			response = response/max(max(response));
			breaks = breaks/max(max(breaks));

			red = ones(size(fixational));
			green = ones(size(red));
			blue = ones(size(red));
			
			green = green - fixational;
			blue = blue - fixational;
			
			red = red - response - breaks;
			blue = blue - response - breaks;

			% red = red - breaks;
			% greeen = green - breaks;
			
			red(red<0) = 0;
			green(green<0) = 0;
			blue(blue<0) = 0;

			image( edge{2}, edge{1}, cat( 3, red, green, blue ) );
			set( gca, 'yDir', 'normal', 'box', 'off' );
			xlabel( 'Amplitude in logarithm (\circ)', 'FontSize', 12 );
			ylabel( 'Peak Velocity in logarithm ( \circ/s)', 'FontSize', 12 );
			title( 'Main Sequence', 'FontSize', 12 );

			% figure;
			% plot( log10([mainSequence.amplitude]), log10([mainSequence.peakSpeed]), '.' );

		end

		function RotationSimulator()
			nTrials = 10000;

			t1		= normrnd( 137, 50, 1, nTrials );	% ms
			t2		= normrnd( 250, 50, 1, nTrials );
			ang1	= normrnd( 90, 15, 1, nTrials );	% degrees
			vel		= normrnd( 1000, 10, 1, nTrials );	% degrees / s
			
			dur		= normrnd( 200, 50, 1, nTrials );
			t2		= t1 + dur;

			ang2 = ang1 + vel .* ( t2 - t1 ) / 1000;

			[ tTicks, rate ] = MyMethods.ShowMicroSacsRate('E:\YBConverted\Abao\colorcue\microSacs','abao');
			cla;
			hold on;

			for( i = 1 : nTrials )
				% plot( [ -200, t1(i) ], [ ang1(i), ang1(i) ], ':' );
				% plot( [ t1(i), t2(i) ], [ ang1(i), ang2(i) ], ':' );
				% plot( [ t2(i), 650 ], [ ang2(i), ang2(i) ], ':' );
				for( j = find( tTicks*1000 == 137 ) : size(rate,2) )
					if( rand < rate(j)*0.001 )
						if( tTicks(j)*1000 < t2(i) )
							plot( tTicks(j)*1000, ang1(i) + vel(i) * ( tTicks(j)*1000 - t1(i) ) / 1000, '.' );
						else
							plot( tTicks(j)*1000, ang2(i), '.' );
						end
						break;
					end
				end
			end



		end

	end
end