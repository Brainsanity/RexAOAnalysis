classdef MyMethods < handle
	
	methods ( Access = private )
		function obj = MyMethods();
		end
	end

	methods ( Static )
		function sc = main( folder, task )
			% folder:		path containing refined data of all subjects (saved by RexBlock)
			%				the structure should be:
			%					folder\
			%						sub_1\
			%							refined_data_folder_1\
			%							...\
			%							refined_data_folder_n\
			%
			%						...\
			%
			%						sub_n\
			%							refined_data_folder_1\
			%							...\
			%							refined_data_folder_n\
			%						
			% task:			scis (SCIS task) or mgs (MGS task)

			subFolders = ToolKit.ListFolders(folder);
			for( iSub = 1 : size(subFolders,1) )	% for each subject
				refinedFolders = ToolKit.ListFolders(subFolders(iSub,:));
				minTrialIndex = 1;
				for( iRefined = 1 : size(refinedFolders,1) )	% for each refined data folder
					microSacs = MyMethods.ExtractMicroSacs( ToolKit.RMEndSpaces( refinedFolders(iRefined,:) ), minTrialIndex, task );
					if( ~isempty(microSacs) ) minTrialIndex = microSacs(end).trialIndex + 1; end
				end
			end
		end

		function microSacs = ExtractMicroSacs( folder, minTrialIndex, task )
			% folder:		path containing refined data (saved by RexBlock)

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( strcmpi(task,'scis') )
				ba = SCueBlocksAnalyzer( ToolKit.ListMatFiles(folder) );
			elseif( strcmpi(task,'mgs') )
				ba = BlocksAnalyzer( 'MemBlock', ToolKit.ListMatFiles(folder) );
			else ba = [];
			end
            if( isempty(ba) || ba.nBlocks == 0 || ba.nCorrect == 0 )    microSacs = []; return; end

			fieldNames = {	'latency',...		% saccade time from trial start (s)
							'duration',...		% duration of saccade (s)
							'angle',...			% direction of saccade (degrees)
							'amplitude',...		% amplitude of saccade (degrees)
							'termiPoints',...	% saccade start and end position (2-by-2: 1st column for start point; 2nd for end point)
							'peakSpeed',...		% peak velocity
							'name',...			% block name
							'trialIndex',...	% trial index count from the first trial of the first block
							'tRf',...			% time of rf on
							'tCue',...			% time of cue on
							'tJmp1',...			% time of jmp1 on
							'rfLoc',...			% location of rf
							'responseLoc',...	% start and end position of response saccade
							'responseAngle',... % direction of response saccade
							'responseAmp',...	% amplitude of response saccade
							'responseLat',...	% latency of response saccade
							'responsePkVel',...	% peak velocity of response saccade
							'responseDur',...	% duration of response saccade
							'cueLoc',...		% cue location
							'tarLoc' };			% target location
			for( i = 1 : size(fieldNames,2) )
				microSacs( 4 * sum( [ ba.blocks.nCorrect ] ) ).( fieldNames{i} ) = [];
			end

			count = 0;
			minTrialIndex = minTrialIndex - 1;

			iLastSlash = find( folder == '/' | folder == '\', 2, 'last' );
			for( iBlock = 1 : ba.nBlocks )
				trials = ba.blocks(iBlock).trials( [ ba.blocks(iBlock).trials.type ] == TRIAL_TYPE_DEF.CORRECT );
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
					[sacs.cueLoc]		= deal( [ trials(i).cue.x; trials(i).cue.y ] );	%%%%%% spatial cue
					[sacs.tarLoc]		= deal( [ trials(i).jmp1.x; trials(i).jmp1.y ] );

					microSacs( count + 1 : count + size(sacs,2) ) = sacs;
					count = count + size(sacs,2);
				end
				minTrialIndex = minTrialIndex + nTrials;
			end
			microSacs( count+1 : end ) = [];
            if( count == 0 ) return; end

			varname = [ 'microSacs', folder( iLastSlash(2) + 1 : end ) ];
			eval( [ varname, '= microSacs;' ] );
			save( [ folder, '/../', varname, '.mat' ], varname );	% save to the upper folder
		end

		function microSacs = LoadMicroSacs( folder )
			% folder:	containing "microSacs*.mat" files (subject folder)

			fileNames = ToolKit.ListMatFiles( folder );
			s = '[';
			for( i = 1 : size(fileNames,1) )
				tmpFn = fileNames( i, find( fileNames(i,:) == '\' | fileNames(i,:) == '/', 1, 'last' ) + 1 : end );
				if( size(tmpFn,2) < 9 || ~strcmp(tmpFn(1:9), 'microSacs') ) continue; end 	% only load .mat files start with "microSacs"
				load( ToolKit.RMEndSpaces( fileNames(i,:) ) );
				s = [ s, ToolKit.RMEndSpaces( fileNames( i, find( fileNames(i,:) == '\' | fileNames(i,:) == '/', 1, 'last' ) + 1 : end ) ) ];				
				s( end-2 : end ) = [];	% remove ".mat"
				s(end) = ',';
			end
			s(end) = ']';
			eval( [ 'microSacs = ', s, ';' ] );
		end

		function SCBias = SCBiasAnalyzer( folder, subject, ang_step, ang_win )
			%% SCBias = SCBiasAnalyzer( folder, subject [,ang_step=10] [,ang_win=20] )
			%    Analyze bias according to statistics of break saccades during different time periods of trials: from fp on to rf on (fp2rf),
			%  from rf on to cue on (rf2cue), and from cue on to jmp1 on (cue2j1); and also analyze bias according to statistics of reporting
			%  saccades in error trials, and in correct trials. This function will save the results to a file named SCBias.mat at the
			%  folder of the parameter "folder", if the results were never saved before
			%
			%  SCBias:		results, the structure can be seen in the code as follow
			%  folder:		subject folder
			%  subject:		specify the subject
			%  ang_step:	angle steps (degrees) when plotting histograms
			%  ang_win:		angle window used to define left or right saccades

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 20; end

			if( exist( [folder,'/SCBias.mat'], 'file' ) == 2 )
				load( [folder,'/SCBias.mat'] );				
			else
				SCBias = [];
				refinedFolders = ToolKit.ListFolders(folder);
				for( iRefined = 1 : size(refinedFolders,1) )
					refinedFolder = ToolKit.RMEndSpaces( refinedFolders(iRefined,:) );
					sc = SCueBlocksAnalyzer( ToolKit.ListMatFiles(refinedFolder) );
					SCBias(end+1).name = refinedFolder( find( refinedFolder == '\', 1, 'last' ) + 1 : end );
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
						breaks = sc.blocks(iBlock).trials( [sc.blocks(iBlock).trials.type] == TRIAL_TYPE_DEF.FIXBREAK );
						if( ~isempty(breaks) )
							%% for SCBias(end).fp2rf
							fp = [breaks.fp];
							rf = [breaks.rf];
							trials = breaks( [fp.tOn] > 0 & [rf.tOn] < 0 );
							if( ~isempty(trials) )
								[ tBreak, breakSacs ] = trials.GetBreak();
								fp = [trials.fp];
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
								[ tBreak, breakSacs ] = trials( [cue.x] < 0 ).GetBreak();
								SCBias(end).cue2j1.tarLeft.angles = [ SCBias(end).cue2j1.tarLeft.angles, [breakSacs.angle] ];
								ePoints = [breakSacs.termiPoints];
	                            if( ~isempty(ePoints) )
	                                SCBias(end).cue2j1.tarLeft.ePoints = [ SCBias(end).cue2j1.tarLeft.ePoints, ePoints(:,2) ];
	                            end
								SCBias(end).cue2j1.tarLeft.time = [ SCBias(end).cue2j1.tarLeft.time, tBreak - [ cue( [cue.x] < 0 ).tOn ] ];
								SCBias(end).nLeftBreaks = SCBias(end).nLeftBreaks + sum( [cue.x] < 0 );

								%% for target right condition
								[ tBreak, breakSacs ] = trials( [cue.x] > 0 ).GetBreak();
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

				save( [folder,'/SCBias.mat'], 'SCBias' );
			end

			%% fp2rf, rf2cue
			for( k = 1 : 2 )				
				if( k == 1 )
					%% fp2rf
					% get data
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
					figName = [ subject,' Breaks After Fp On Before Candidates On' ];
					figDirectTitle = 'Direction distribution of break saccades before candidates on';
					figTimeTitle = 'Time distribution of break saccades before candidates on';
				else
					%% rf2cue
					% get data
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
					figName = [ subject, ' Breaks After Candidates On Before Cue On' ];
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
				errorbar( 1, mean(left), std(left)/2, std(left)/2, 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right)/2, std(right)/2, 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
				set( gca, 'FontSize', FontSize, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				if( mean(left) < mean(right) )	tail = 'left';
				else 							tail = 'right'; end
				% tail = 'both';
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
			if( strcmpi( subject, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( subject, 'datou' ) )
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Breaks After Cue On (Population)' ] );
			
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Breaks After Cue On (Significance)' ] );

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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Trials After Cue On (Ratio)' ] );

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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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
			if( strcmpi( subject, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( subject, 'datou' ) )
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Error ratio' ] );
			
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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', FontSize );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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

		%%%%%%
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
				errorbar( 1, mean(left), std(left)/2, std(left)/2, 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right)/2, std(right)/2, 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'left' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		%%%%%%
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
				errorbar( 1, mean(left), std(left)/2, std(left)/2, 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right)/2, std(right)/2, 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'left' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		%%%%%%
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
				errorbar( 1, mean(left), std(left)/2, std(left)/2, 'color', 'g' );
				text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
				bar( 2, mean(right), 0.5, 'r' );
				errorbar( 2, mean(right), std(right)/2, std(right)/2, 'color', 'r' );
				text( 2, 0, 'Right', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
				set( gca, 'xtick', [], 'xlim', [0 3], 'ylim', [0 1] );
				text( 2.7, 0.9, sprintf( 'p = %f', ranksum( left, right, 'tail', 'both' ) ), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'FontSize', 12  );
				title( [ 'Window: +-', num2str(ang_win), '\circ' ], 'FontSize', 12 );
				ylabel( 'Proportion (%)', 'FontSize', 12 );
			end
		end

		%%%%%%
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

		function nTrials = CountNTrials( folder, task )
			%% Count number of trials in each block for left correct, left error, right correct, left error, and breaks
			%  nTrials:
			%		nTrials(iBlock).blockName				file name of the i-th block
			%		nTrials(iBlock).left.correct 			nubmer of correct trials with target left, in i-th block
			%		nTrials(iBlock).left.error 				nubmer of error trials with target left, in i-th block
			%		nTrials(iBlock).right.correct 			nubmer of correct trials with target right, in i-th block
			%		nTrials(iBlock).right.error 			nubmer of error trials with target right, in i-th block
			%		nTrials(iBlock).breaks 					number of break trials, in i-th block
			%  folder:		subject folder
			%  task:		scis or mgs

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( exist( [folder,'/nTrials.mat'], 'file' ) == 2 )
				load( [folder,'/nTrials.mat'] );

			else
				refinedFolders = ToolKit.ListFolders(folder);
				for( iRefined = 1 : size(refinedFolders,1) )
					fileNames = ToolKit.ListMatFiles( refinedFolders(iRefined,:) );
					for( iFile = size(fileNames,1) : -1 : 1 )
						fileName = ToolKit.RMEndSpaces( fileNames(iFile,:) );
						nTrials(iFile).blockName = fileName( find( fileName == '\', 1, 'last' ) + 1 : end );
						switch( lower(task) )
							case 'scis'
								rb = SCueBlock( [], fileName, RexBlock.REFINED_FILE, DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
							case 'mgs'
								rb = MemBlock( [], fileName, RexBlock.REFINED_FILE, DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
						end
						if( rb.nTrials == 0 ), continue; end
						
						correctTrials = rb.trials( [ rb.trials.type ] == TRIAL_TYPE_DEF.CORRECT );
						nTrials(iFile).left.correct = 0;
						nTrials(iFile).right.correct = 0;
						if( ~isempty(correctTrials) )
							jmp1 = [correctTrials.jmp1];
							tarLocs = [ jmp1.x; jmp1.y ];
							nTrials(iFile).left.correct = sum( tarLocs(1,:) < 0 & tarLocs(2,:) == 0 );
							nTrials(iFile).right.correct = sum( tarLocs(1,:) > 0 & tarLocs(2,:) == 0 );
						end
						
						errorTrials = rb.trials( [rb.trials.type] == TRIAL_TYPE_DEF.ERROR );
						nTrials(iFile).left.error = 0;
						nTrials(iFile).right.error = 0;
						if( ~isempty(errorTrials) )
							jmp1 = [errorTrials.jmp1];
							tarLocs = [ jmp1.x; jmp1.y ];
							nTrials(iFile).left.error = sum( tarLocs(1,:) < 0 & tarLocs(2,:) == 0 );
							nTrials(iFile).right.error = sum( tarLocs(1,:) > 0 & tarLocs(2,:) == 0 );
						end

						nTrials(iFile).break = size( rb.trials( [rb.trials.type] == TRIAL_TYPE_DEF.FIXBREAK ), 2 );
					end
				end
				save( [folder,'/nTrials.mat'], 'nTrials' );
			end
		end

		function microSacs = Get1stAfter( microSacs, field, t )
			%%   Define a time point as t after a given event (specified by "field", e.g., tCue, tRf, tJmp1),
			%  then remove any microsaccade which is not the first microsaccade after that time point of any trial

			index1 = find( [microSacs.latency] - [microSacs.(field)] > t );
			trialIndex = [microSacs(index1).trialIndex];
			index2 = index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );	% sacs after the 1st one
			% index1( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];	% 1st sacs
			% trialIndex = [microSacs(index2).trialIndex];
			% index3 = index2( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ); % sacs after the 2nd one

			microSacs(index2) = [];	% 1st sacs
		end

		function tStart = GetTStart( folder, subject, task )
			% folder:	subject folder
			% subject:	specify subject; if tStart.mat exists in folder, then not needed
			% task:		scis or mgs; if tStart.mat exists in folder, then not needed

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( exist( [folder,'/tStart.mat'], 'file' ) == 2 )
				load( [folder,'/tStart.mat'] );

			else
				[rate, tTicks] = MyMethods.ShowMicroSacsRate( folder, subject, task, false );
				[~,index] = min( rate( 0 < tTicks & tTicks < 0.2 ) );	% find the lowest point within [0, 200ms ] after cue on
				tStart = tTicks( find( 0 < tTicks, 1, 'first' ) - 1 + index ) + 0.03;	% 30 ms after the lowest time point

				save( [folder,'/tStart.mat'], 'tStart' );
			end
		end

		function [edges,data] =  ShowPopulation( folder, subject, ampEdges )
			% folder:	subject folder; not needed if already called for this subject
			% subject:	specify subject
			% ampEdges:	[min amplitude, max amplitude], look at microsaccades with specified amplitude range; [0, 1] by default

			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowPopulation( folder, subject, ampEdges = [0,1] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			tStart = MyMethods.GetTStart( folder, subject, 'scis' );

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );

			microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > -.22 );			
			microSacs = MyMethods.Get1stAfter( microSacs, 'tCue', tStart );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tCue] < 0.6 );
			
			n = floor( size(microSacs,2) / 8 );
			
			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', subject, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

			t_step = 0.01;
			ang_step = 2;

			tarLoc = [microSacs.tarLoc];
			cueLoc = [microSacs.cueLoc];
			index = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0; cueLoc(2,:) > 0; cueLoc(2,:) < 0 ];

			%% show raw data
			cmax = 0;	
			edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };
			% edges = { -0.7 : t_step : 0, 0 : ang_step : 360 };	% for responsive saccade on alignment
			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tCue];
				% t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).responseLat] - [microSacs(index(i,:)).tJmp1];	% for responsive saccade on alignment
				ang = [microSacs(index(i,:)).angle];
				ang(ang<0) = ang(ang<0) + 360;
				cdata = hist3( [t; ang]', 'edges', edges );
				tmax = max(cdata(:));
				if( cmax < tmax ) cmax = tmax; end
			end

			colormap('hot');
			cmp = colormap;
			for( i = 1 : size(index,1) )
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tCue];
				% t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).responseLat] - [microSacs(index(i,:)).tJmp1];	% for responsive saccade on alignment
				ang = [microSacs(index(i,:)).angle];
				ang( ang < 0 ) = ang( ang < 0 ) + 360;

				subplot(2,2,i); hold on;
				cdata = hist3( [t; ang]', 'edges', edges )';
				cdata( isnan(cdata) ) = 0;
	            if( ~isempty(cdata) )
	            	data{i} = cdata;

	                colour = cdata/cmax;
	                red = ones(size(cdata)) - cdata/cmax;
	                green = ones(size(red)) - cdata/cmax;
	                green(green<1) = green(green<1)/1.2;
	                blue = green;

	                nColors = size(cmp,1) - 1;
	                colour = reshape( cmp( round( cdata * nColors / cmax ) + 1 , : ), [ size(cdata), 3 ] );
	                image( edges{1}, edges{2}, colour );
	            end
	            pause(0.6);

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

				% cue on time
				y = get( gca, 'ylim' );
				plot( [0 0], y, 'g:' );
				text( 0, y(2), 'cue on', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );

				% number of trials
				nTrials = MyMethods.CountNTrials( folder, 'scis' );
	            left = [nTrials.left];
	            right = [nTrials.right];
	            nTrials = sum([left.correct]) + sum([right.correct]);
				x = get(gca,'xlim');
				text( x(2), y(2), sprintf( 'nTrials: %d', nTrials ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );

				%% linear fitting for microsaccades at the bottom-rifht corner of the fourth figure: abao
				%% linear fitting for microsaccades at the top-rifht corner of the fourth figure: datou
				nUp	  = sum( ang < 180 & t > tStart );
				nDown = sum( ang > 180 & t > tStart );
				label = [];
				ratio = 0;
				angRange = 0:180;
				tmpIndex = ang < 180 & t > tStart;
				ratio = nUp / ( nUp + nDown );
				
				tmpAng = ang(tmpIndex);
				tmpT = t(tmpIndex);

				% fitting
				p = polyfit( tmpT, tmpAng, 1);
				[r pval] = corrcoef( tmpT, tmpAng );
                if( size(r,2) == 1 ) r(2) = r(1); end
                if( size(pval,2) == 1) pval(2) = pval(1); end
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
		end

		function FirstVSSecond( folder, subject, task )
			% folder:	subject folder
			% subject:	specify subject; if tStart.mat exists in folder, then not needed
			% task:		scis or mgs; if tStart.mat exists in folder, then not needed

			if( nargin() < 3 ), disp( 'Usage: MyMethods.FirstVSSecond( folder, subject, task )' ); return; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			tStart = MyMethods.GetTStart( folder, subject, task );

			if( strcmpi( task, 'scis' ) )
				microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );
			elseif( strcmpi( task, 'mgs' ) )
            	microSacs = microSacs( [microSacs.latency] - [microSacs.tRf] > tStart );
            end

            tarLocs = [microSacs.tarLoc];
			microSacs = microSacs( tarLocs(2,:)==0 );

			iFirst = find( [ microSacs(1:end-1).trialIndex ] == [ microSacs(2:end).trialIndex ] );
			FirstAngs = [microSacs(iFirst).angle];
			SecondAngs = [microSacs(iFirst+1).angle];
			SecondAngs( SecondAngs < 0 ) = SecondAngs( SecondAngs < 0 ) + 360;

			ang_step = 5;

			cdata = hist3( [FirstAngs; SecondAngs]', 'edges', { -180:ang_step:180, 0:ang_step:360 } )';

			set( figure, 'NumberTitle', 'off', 'name', [ subject, '_', task ] ); hold on;
			colormap('hot');
			cmp = colormap;
			caxis( [0 max(cdata(:))] );
			colorbar('color','w','FontSize',30);

			nColors = size(cmp,1) - 1;
	        colour = reshape( cmp( round( cdata * nColors / max(cdata(:)) ) + 1 , : ), [ size(cdata), 3 ] );
			image( -180:ang_step:180, 0:ang_step:360, colour );

			plot( [-180 180], [0 360], 'w--', 'LineWidth', 1 );
			plot( [-180 180], [360 0], 'w--', 'LineWidth', 1 );
			axis equal;
			set(gca, 'layer', 'top', 'color', 'k', 'XColor', 'w', 'YColor', 'w', 'xlim',[-180 180], 'ylim', [0 360], 'xtick', [-180:90:180], 'ytick', [0:90:360], 'FontSize', 30);
			xlabel( 'Fist saccade direction (\circ)', 'FontSize', 30 );
			ylabel( 'Second saccade direction (\circ)', 'FontSize', 30 );
			if( strcmpi( task, 'scis' ) )
				title( 'First saccade VS Second saccade (from cue onset)', 'FontSize', 30 );
			else
				title( 'First saccade VS Second saccade (from target onset)', 'FontSize', 30 );
			end
		end

		function [ rate, tTicks ] = ShowMicroSacsRate( folder, subject, task, isDraw )
			%% plot microsaccades rate (within 1 degree)
			% folder:	subject folder
			% subject:	specify subject
			% task:		scis or mgs
			%  isDraw:				whether draw the figure; default is true

			if( nargin() < 4 ) isDraw = true; end

			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			microSacs( [microSacs.amplitude] > 1 ) = [];

			tarLocs = [microSacs.tarLoc];
			microSacs = microSacs(tarLocs(2,:)==0);

			latency = [microSacs.responseLat];

            nTrials = MyMethods.CountNTrials( folder, task );
            left = [nTrials.left];
            right = [nTrials.right];
            nTrials = sum([left.correct]) + sum([right.correct]);

            switch( lower(task) )
				case 'scis'
					t = [microSacs.latency] - [microSacs.tCue];		% aligned to cue on
				case 'mgs'
					t = [microSacs.latency] - [microSacs.tRf];		% aligned to target (rf) on
			end

            t_step = 0.001;
            tTicks = min(t) : t_step : max(t);
            rate = ToolKit.Hist( t, [ tTicks - t_step/2, tTicks(end) + t_step/2 ], false );
            SIGMA = 5;
            func = @(x) exp( -.5*(x/SIGMA).^2 ) / ( sqrt(2*pi)*SIGMA );
            % rate = conv( rate, func(-20:20)/0.001/nTrials, 'same' );
            rate = conv( rate, ones(1,5)/5/0.001/nTrials, 'same' );		% smooth the rate curve
            if( isDraw )
	            set( figure, 'NumberTitle', 'off', 'name', sprintf( '[%s] [%s] Microsaccades Rate', subject, task ) ); hold on;
	            FONTSIZE = 36;
	            plot( min(t) : t_step : max(t), rate );
	            plot( [0 0], get( gca, 'ylim' ), 'k:' );
	            set( gca, 'FontSize', FONTSIZE );
	            xlabel( 'Time from cue on (s)', 'FontSize', FONTSIZE );
	            ylabel( 'Microsaccades rate (Hz)', 'FontSize', FONTSIZE );
	            hold off;
	        end
		end

		%%%%%%
		function RTData = RankSumTest( folder, subject, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.RankSumTest( folder, subject, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,5]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end		

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			% tStart = -.25;
			% if( strcmpi( subject, 'abao' ) )
			% 	tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			% elseif( strcmpi( subject, 'datou' ) )
			% 	tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
			% 	% tStart = 0;
			% else
			% 	return;
			% end
			% tStart = 0;
			tStart = MyMethods.GetTStart( subject, 'asc' );

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
						% cueLoc(1,:) < 0 & tarLoc(2,:) ~= 0;...
						cueLoc(1,:) > 0 & tarLoc(2,:) == 0;...
						% cueLoc(1,:) > 0 & tarLoc(2,:) ~= 0;...
						];
            names = { 'left', 'oblique left', 'right', 'oblique right' };
            names = names([1 3]);

			% for( i = 24 : -1 : 1 )
			% 	index( i, : ) = cueLoc(1,:) == cueLocs(1,i) & cueLoc(2,:) == cueLocs(2,i) & tarLoc(2,:) == 0;
			% end
   			%names = eval( [ '{' sprintf( '''%4d%4d'',', cueLocs ) '}' ] );

   			%% for 4Quadrants
   			index = [...
   						cueLoc(1,:) < 0 & cueLoc(2,:) > 0 & tarLoc(2,:) == 0;...
   						cueLoc(1,:) < 0 & cueLoc(2,:) < 0 & tarLoc(2,:) == 0;...
   						cueLoc(1,:) > 0 & cueLoc(2,:) > 0 & tarLoc(2,:) == 0;...
   						cueLoc(1,:) > 0 & cueLoc(2,:) < 0 & tarLoc(2,:) == 0;...
   					];
   			names = { 'UpperLeft', 'LowerLeft', 'UpperRight', 'LowerRight' };

   			%% for MiddleVSLateral
   			index = [...
   						cueLoc(1,:) < 0 & cueLoc(1,:) > -8;...
   						cueLoc(1,:) < 0 & cueLoc(1,:) < -8;...
   						cueLoc(1,:) > 0 & cueLoc(1,:) < 8;...
   						cueLoc(1,:) > 0 & cueLoc(1,:) > 8;...
   					];
   			names = { 'LeftMiddle', 'LeftLateral', 'RightMiddle', 'RightLateral' };

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
					if( strcmpi( subject, 'abao' ) )
						rankTestIndex = rankTestIndex & ( angles < 0 & t > 0 | t < 0 );
					elseif( strcmpi( subject, 'datou' ) )
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
            if( strcmpi( subject, 'abao' ) )	% base line for abao: population vector
            	ind = 1 : round( ( 0 - RTData.tStart ) / RTData.bin )
            	% EX(:,ind) = cellfun( @(c) cart2pol( cos((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)', sin((-179.5:179.5)/180*pi) * ToolKit.Hist(c,-180:180)' )/pi*180, RTData.data(:,ind) );
            end
            STD = cellfun( @(c) nanstd(c), RTData.data );
            SEM = cellfun( @(c) nanstd(c) / sqrt(size(c,2)), RTData.data );
            % x = RTData.tStart + RTData.bin/2 : RTData.bin : RTData.tEnd - RTData.bin/2;
            % x = RTData.tStart + RTData.bin/2 : 0.001 : RTData.tStart + RTData.bin/2 + ( nPoints - 1 ) * 0.001;
            x = RTData.tStart : 0.001 : RTData.tEnd;
            for( i = 1 : size(EX,1) )
            	if( i < 13 )	colour = [ (i-1) / (size(index,1)+1), (i-1) / (size(index,1)+1), 1 ];
            	else 			colour = [ 1, (i-13) / (size(index,1)+1), (i-13) / (size(index,1)+1) ];	end
            	% if( i <= 4 )		colour = [ 1, (i-1) / 6 , (i-1) / 6  ];
            	% elseif( i <= 8 )	colour = [ (i-5) / 6 , 1, (i-5) / 6  ];
            	% elseif( i <= 12 )	colour = [ (i-9) / 6 , (i-9) / 6 , 1 ];
            	% elseif( i <= 16 )	colour = [ 1, 1, (i-13) / 6  ];
            	% elseif( i <= 20 )	colour = [ (i-17) / 6 , 1, 1 ];
            	% else				colour = [ 1, (i-21) / 6 , 1 ];	end
            	if( i <= 2 )	colour = [ 1, (i-1) / 3, (i-1) / 3 ];
            	else 			colour = [ (i-3) / 3, (i-3) / 3, 1 ]; end
            	% if( i == 1 ) colour = [ 0, 0, 1 ];
            	% else 		 colour = [ 1, 0, 0 ]; end
            	ToolKit.ErrorFill( x, EX(i,:), SEM(i,:), [0 0 0], 'LineStyle', 'none', 'FaceColor', min( [ colour; 1,1,1 ] ));%, 'FaceAlpha', 0.8 );
            	h(i) = plot( x, EX(i,:), 'LineWidth', 2, 'color', colour, 'DisplayName', names{i} );
            	% plot( x, SPEED(i,:), 'LineWidth', 2, 'color', colour );
            	% h(i) = errorbar( x, EX(i,:), SEM(i,:)/2, SEM(i,:)/2, 'color', colour, 'LineWidth', 2, 'marker', '.', 'DisplayName', names{i} );

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
            	if( strcmpi( subject, 'abao' ) )
					tmpAng = angles( index(i,:) & angles < 0 & t > RTData.tStart );
					tmpT = t( index(i,:) & angles < 0 & t > RTData.tStart );
				elseif( strcmpi( subject, 'datou' ) )
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
            set( legend( h, 'location', 'NorthEastOutside' ), 'FontSize', 12 );
            set( gca, 'xtick', 0.1:0.1:0.6, 'xlim', [0.09 0.62], 'FontSize', 36 );
            xlabel( 'Time from cue on (s)', 'FontSize', 36 );
            ylabel( 'Microsaccades direction (\circ)', 'FontSize', 36 );
            return;
 			
 			ang_step = 10;
            if( strcmpi( subject, 'abao' ) )
            	edges = -180 : ang_step : 0;
            elseif( strcmpi( subject, 'datou' ) )
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

		%%%%%%
		function [ stats, pVal ] = SlopeTest( folder, subject, ampEdges )
			if( nargin() < 2 ), disp( 'Usage: MyMethods.SlopeTest( folder, subject, ampEdges = [0,5], isOblique = false )' ); return; end
			if( nargin() < 3 ), ampEdges = [0,5]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			% tStart = -.25;
			% if( strcmpi( subject, 'abao' ) )
			% 	tStart = 0.081 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.082 smoothed with a Gaussian)
			% elseif( strcmpi( subject, 'datou' ) )
			% 	tStart = 0.099 + 0.03;		% lowest time point plus an extra 30ms in rate plot		(0.102 smoothed with a Gaussian)
			% 	tStart = 0.106 + 0.03;
			% 	% tStart = 0;
			% else
			% 	return;
			% end
			tStart = MyMethods.GetTStart( subject, 'asc' );

			microSacs = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );

			index = find( [microSacs.latency] - [microSacs.tCue] > tStart );
					
			trialIndex = [microSacs(index).trialIndex];
			index = index( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 );
			microSacs(index) = [];
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) & [microSacs.latency] - [microSacs.tCue] < 0.6 );

			%% correlation with target location
			tarLoc = [microSacs.tarLoc];
			% microSacs = microSacs( tarLoc(2,:) == 0 );
			% mss{2} = microSacs( tarLoc(2,:) ~= 0 );
			mss{1} = microSacs( tarLoc(2,:) == 0 );
			mss{2} = mss{1};

			%% for 4Quadrants
			cueLoc = [microSacs.cueLoc];
			mss{1} = microSacs( tarLoc(2,:) == 0 & cueLoc(2,:) > 0 );
			mss{2} = microSacs( tarLoc(2,:) == 0 & cueLoc(2,:) < 0 );

			%% for MiddleVSLateral
			mss{1} = microSacs( tarLoc(2,:) == 0 & ( cueLoc(1,:) > -8 & cueLoc(1,:) < 8 ) );	% middle
			mss{2} = microSacs( tarLoc(2,:) == 0 & ( cueLoc(1,:) < -8 | cueLoc(1,:) > 8 ) );	% letaral

			%% correlation with response saccade latency
			% latency = [microSacs.responseLat];
			% mss{2} = microSacs( latency < 0.05 );
			% mss{1} = microSacs( latency > 0.13 );

			%% correlation with response saccade endpoint
			% respLoc = [microSacs.responseLoc];
			% meanL = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			% meanR = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) < meanR | respLoc(1,:) < 0 & respLoc(1,:) > meanL );
			% mss{1} = microSacs( respLoc(1,:) > 0 & respLoc(1,:) > meanR | respLoc(1,:) < 0 & respLoc(1,:) < meanL );

			%% correlation with response saccade amplitude
			% amplitude = [microSacs.responseAmp];
			% amplitude = [microSacs.responseDur];
			% meanL = mean( amplitude( respLoc(1,:) < 0 ) );
			% meanR = mean( amplitude( respLoc(1,:) > 0 ) );
			% meanL = median( amplitude( respLoc(1,:) < 0 ) )
			% meanR = median( amplitude( respLoc(1,:) > 0 ) )
			% figure;hist( amplitude, 5:0.5:15 ); return;
			% mss{2} = microSacs( respLoc(1,:) < 0 & amplitude < meanL | respLoc(1,:) > 0 & amplitude < meanR );
			% mss{1} = microSacs( respLoc(1,:) < 0 & amplitude > meanL | respLoc(1,:) > 0 & amplitude > meanR );
			% sortedAmp = { sort( amplitude( respLoc(1,:) < 0 ) ), sort( amplitude( respLoc(1,:) > 0 ) ) };
			% figure;			
			% for( i = 2 : -1 : 1 )
			% 	subplot( 1, 2, i );
			% 	hist( sortedAmp{i}, 5:0.2:15 );
			% 	set( gca, 'xlim', [4 16] );
			% 	MEAN = mean( sortedAmp{i} );
			% 	STD = std( sortedAmp{i} );
			% 	sortedAmp{i} = sortedAmp{i}( MEAN - 2*STD <= sortedAmp{i} & sortedAmp{i} <= MEAN + 2*STD );
			% 	st = floor( size( sortedAmp{i}, 2 ) / 8 );
			% 	bounds{i}.start = sortedAmp{i}( 1 : 30 : end-st );
			% 	bounds{i}.end = sortedAmp{i}( st : 30 : end );
			% end
			% bounds = { sortedAmp{1}( 1 : floor( size(sortedAmp{1},2)/8 ) : end ), sortedAmp{2}( 1 : floor( size(sortedAmp{2},2)/8 ) : end ) };
			% bounds{1}(1) = bounds{1}(1) - 0.001;
			% bounds{2}(1) = bounds{2}(1) - 0.001;
			% for( i = size(bounds{1},2)-1 : -1 : 1 )
			% 	mss{i} = microSacs( respLoc(1,:) < 0 & bounds{1}(i) <= amplitude & amplitude <= bounds{1}(i+1) |...
			% 						respLoc(1,:) > 0 & bounds{2}(i) <= amplitude & amplitude <= bounds{2}(i+1) );
			% end

			%% correlation with response saccade endpoint accuracy
			% respLoc = [microSacs.responseLoc];
			% centerLX = mean( respLoc( 1, respLoc(1,:) < 0 ) );
			% centerLY = mean( respLoc( 2, respLoc(1,:) < 0 ) );
			% centerRX = mean( respLoc( 1, respLoc(1,:) > 0 ) );
			% centerRY = mean( respLoc( 2, respLoc(1,:) > 0 ) );
			% mss{2} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) < 0.6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) < 0.6 );
			% mss{1} = microSacs( respLoc(1,:) < 0 & sqrt( ( respLoc(1,:) - centerLX ).^2 + ( respLoc(2,:) - centerLY ).^2 ) > .6 | ...
			% 					respLoc(1,:) > 0 & sqrt( ( respLoc(1,:) - centerRX ).^2 + ( respLoc(2,:) - centerRY ).^2 ) > .6 );

			%% correlation with response saccade duration



			nGroups = [ 8 8 ];
			% nGroups = [ 7 7 ];
			% nGroups = ones(1,size(bounds{1},2)-1);
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
		            	if( strcmpi( subject, 'abao' ) )
							tmpAng = angles( index(i,:) & angles < 0 & t > tStart );
							tmpT = t( index(i,:) & angles < 0 & t > tStart );
							angRange = -180:0;
						elseif( strcmpi( subject, 'datou' ) )
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

			% figure; hold on;
			% colors = {'r','b'};
			% for( i = 1 : 2 )
			% 	plot( ( bounds{i}(1:end-1) + bounds{i}(2:end) ) / 2, ([ stats(:,1,i).coefs ]), '*-', 'color', colors{i} );
			% end
			% return;


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
			colors = colors( [3 4 1 2] );

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
				plot( [ i, i ], EX(i) + [ -SEM(i), SEM(i) ], 'LineWidth', 2, 'color', 'k' );% 'r' );
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

			%set( gca, 'xlim', [0 5], 'xtick', 1:4, 'xTickLabel', { 'L', 'OL', 'R', 'OR' }, 'FontSize', FONTSIZE );
			%% for MiddleVSLateral
			set( gca, 'xlim', [0 5], 'xtick', 1:4, 'xTickLabel', { 'ML', 'LL', 'MR', 'LR' }, 'FontSize', FONTSIZE );
			% y = get( gca, 'ylim' );
			% text( 1.5, y(2), sprintf( '%.4f', pVal.L_OL ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			% text( 3.5, y(2), sprintf( '%.4f', pVal.R_OR ), 'FontSize', 12, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center' );
			ylabel( 'Microsaccades direction rotation speed (\circ/s)', 'FontSize', FONTSIZE );
		end

		%%%%%%
		function OtherCorr( folder, subject, parameter, ampEdges )
			if( nargin() < 3 ), disp( 'Usage: MyMethods.SlopeTest( folder, subject, parameter, ampEdges = [0,5], isOblique = false )' ); return; end
			if( nargin() < 4 ), ampEdges = [0,5]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			cueLocs = [ -12 -12 -12 -12  -8  -8  -8  -8  -4  -4  -4  -4   4   4   4   4   8   8   8   8  12  12  12  12;...
						-10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 -10  -5   5  10 ];

			field = 'tCue';
			% field = 'tRf';
			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );
			tStart = MyMethods.GetTStart( subject, 'asc' );
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
			set( figure, 'NumberTitle', 'off', 'name', [ subject, '_Response', parameter ] );
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
	            	if( strcmpi( subject, 'abao' ) )
						tmpAng = angles( angles < 0 );
						tmpT = t( angles < 0 );
						angRange = -180:0;
					elseif( strcmpi( subject, 'datou' ) )
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, '_Slope.VS.Response', parameter ] ); hold on;
			colors = {'r','b'};
			for( i = 1 : 2 )
				plot( ( bounds{i}.start + bounds{i}.end ) / 2, abs([ stats{i}.coefs ]), '.-', 'color', colors{i} );
			end
			return;
		end

		function params = AmplitudeFitting( folder, subject, task, fitKernel, isUni )
			if( nargin() <= 3 ) fitKernel = 'gev'; end
			if( nargin() <= 4 ) isUni = false; end

			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end
			
			tStart = MyMethods.GetTStart( folder, subject, task );
        	if( strcmpi( task, 'scis' ) )
        		index = [microSacs.latency] - [microSacs.tCue] > tStart;
			elseif( strcmpi( task, 'mgs' ) )
				index = [microSacs.latency] - [microSacs.tRf] > tStart;
			else
				params = [];
				return;
			end

			microSacs = microSacs(index);
			
			trialIndex = [microSacs.trialIndex];
			microSacs( find( trialIndex(2:end) - trialIndex(1:end-1) == 0 ) + 1 ) = [];

			tarLoc = [microSacs.tarLoc];
			microSacs( tarLoc(2,:) ~= 0 ) = [];
			amplitude = double( [ microSacs.amplitude ] );

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
			FONTSIZE = 24;
			set( gcf, 'NumberTitle', 'off', 'name', [ 'AmplitudeDistribution_', subject, '__', fitKernel ] );

			amp_step = .1;
			edges = min(amplitude) - amp_step/2 : amp_step : max(amplitude) + amp_step/2;
			ToolKit.Hist( amplitude, edges, true, true );

			% plot( log( ( edges(1:end-1) + edges(2:end) ) / 2 ), log(ToolKit.Hist(amplitude,edges,false)) ); return;
			
			set( gca, 'xlim', [0 max(amplitude)*2] );
			set(get(gca,'child'),'LineStyle','none');
			ToolKit.BorderText( 'InnerTopRight', sprintf( 'nTrials: %d', size( unique([microSacs.trialIndex]), 2 ) ), 'FontSize', 12 );

			% X = ( edges(1:end-1) + edges(2:end) ) / 2;
			X = edges(1) : 0.001 : edges(end);
			h(1) = plot( X, amp_step * pdffun( X, params{:} ), 'r', 'LineWidth', 2 );
			h(2) = plot( X, amp_step * params{1} * pdf( distName1, X, params{ iParams(1,1) : iParams(1,2) } ), 'g--', 'LineWidth', 2 );
			h(3) = plot( X, amp_step * ( 1 - params{1} ) * pdf( distName2, X, params{ iParams(2,1) : iParams(2,2) } ), 'y--', 'LineWidth', 2 );
			fill( [ 0:0.001:1 1:-0.001:0 ], [ amp_step * ( 1 - params{1} ) * pdf( distName2, 0:0.001:1, params{ iParams(2,1) : iParams(2,2) } ), zeros(1,1001) ], [0 0 0], 'LineStyle', 'none', 'FaceColor', 'g', 'FaceAlpha', 0.5 );
			plot( [1 1], [ 0 amp_step * pdffun( 1, params{:} ) ], 'r--', 'LineWidth', 2 );
			legend( h, 'sum', 'first', 'second', 'location', 'east' );

			ToolKit.BorderText( 'InnerTop', sprintf( [ ...
				'chi2gof: p = %.4f\n'...
				'    kstest: p = %.4f\n'...
				'params: ', repmat('%.4f ',1,size(params,2)) '\n'...
				'First: %.4f    Second: %.4f' ],...
				chi2_p(ind), ks_p(ind), [params{:}],...
				params{1} * cdf( distName1, 1, params{ iParams(1,1) : iParams(1,2) } ),...
				( 1 - params{1} ) * cdf( distName2, 1, params{ iParams(2,1) : iParams(2,2) } ) ), 'FontSize', 12 );
			if( strcmpi( fitKernel, 'gev' ) )
				y = get(gca,'ylim');
				text( 0, y(2), sprintf('$f(x)=%.3fgevpdf(x,%.3f,%.3f,%.3f)+%.3fgevpdf(x,%.3f,%.3f,%.3f)$',params{1:4},1-params{1},params{5:7}), 'interpreter', 'latex', 'FontSize', 12, 'VerticalAlignment', 'bottom' );
			end
			set( gca, 'FontSize', FONTSIZE );
			xlabel( 'Saccade amplitude (\circ)', 'FontSize', FONTSIZE );
			ylabel( 'Proportion (%)', 'FontSize', FONTSIZE );

			return;
		end

		function ShowMemoryPopulation( folder, subject, ampEdges )
			% folder:	subject folder; not needed if already called for this subject
			% subject:	specify subject
			% ampEdges:	[min amplitude, max amplitude], look at microsaccades with specified amplitude range; [0, 1] by default

			if( nargin() < 2 ), disp( 'Usage: MyMethods.ShowmemoryPopulation( folder, subject, ampEdges = [0,1] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			tStart = MyMethods.GetTStart( folder, subject, 'mgs' );
			microSacs = MyMethods.Get1stAfter( microSacs, 'tRf', tStart );
			microSacs = microSacs( ampEdges(1) <= [microSacs.amplitude] & [microSacs.amplitude] < ampEdges(2) );%& [microSacs.latency] - [microSacs.tCue] > tStart );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'Population_', subject, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);
			
			tarLoc = round([microSacs.tarLoc]);
			rfLoc = [microSacs.rfLoc];
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
			% index = index( [4 6], : );	% only horizontal left and right

			tIndex = index(1,:);
			for( i = 2 : size(index,1) );
				tIndex = tIndex | index(i,:);
			end
			t = [microSacs(tIndex).latency] - [microSacs(tIndex).tRf];
			tMax = max(t);

			t_step = 0.01;
			ang_step = 2;
			tMin = -0.22; % -0.22
			tMax = 1.6;	% max(t)
			% tMin = -1.6;	% for responsive saccade on alignment
			% tMax = 0;		% for responsive saccade on alignment
			% edges = { tMin : t_step : tMax + t_step/2, -180 : ang_step : 180 };
			edges = { tMin : t_step : tMax + t_step/2, 0 : ang_step : 360 };
			% edges = { -0.22 : t_step : 0.6, 0 : ang_step : 360 };

			%% show raw data
			cmax = 0;
			for( i = 1 : size(index,1) )
				if( i == 5 ) continue; end
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				% t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).responseLat] - [microSacs(index(i,:)).tJmp1];	% for responsive saccade on alignment
				ang = [microSacs(index(i,:)).angle];
				ang(ang<0) = ang(ang<0) + 360;
				cdata = hist3( [t; ang]', 'edges', edges );
				tmax = max(max(cdata));
				if( cmax < tmax ) cmax = tmax; end
			end
			colormap('hot');
			cmp = colormap;

			for( i = 1 : size(index,1) )
				if( i == 5 ) continue; end
				t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).tRf];
				% t = [microSacs(index(i,:)).latency] - [microSacs(index(i,:)).responseLat] - [microSacs(index(i,:)).tJmp1];	% for responsive saccade on alignment
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

				%% time points of several events				
				% rf on time
                y = get( gca, 'ylim' );
				plot( [0 0], y, 'g:' );
				text( 0, y(2), 'target', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 12 );

				% number of trials
				nTrials = MyMethods.CountNTrials( folder, 'mgs' );
	            left = [nTrials.left];
	            right = [nTrials.right];
	            nTrials = size([left.correct],2) + size([right.correct],2);
				x = get(gca,'xlim');
				text( x(2), y(2), sprintf( 'nTrials: %d', nTrials ), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right' );
				
				xlabel( [ 'Time from ', 'target on (s)' ], 'FontSize', 12 );
				ylabel( [ 'Microsaccade direction (\circ)' ], 'FontSize', 12 );
	        end
		end

		function MemBias = MemBiasAnalyzer( folder, subject, ang_step, ang_win )
			%% MemBias = MemBiasAnalyzer( folder, subject [,ang_step=10] [,ang_win=20] )
			%    Analyze bias according to statistics of break saccades during different time periods of trials: from fp on to rf on (fp2rf),
			%  and from rf on to jmp1 on (rf2j1); and also analyze bias according to statistics of reporting
			%  saccades in error trials, and in correct trials. This function will save the results to a file named MemBias.mat at the 
			%  folder of the parameter "folder", if the results were never saved before
			%
			%  MemBias:		results, the structure can be seen in the code as follow
			%  folder:		subject folder
			%  subject:		specify the subject
			%  ang_step:	angle steps (degrees) when plotting histograms
			%  ang_win:		angle window used to define left or right saccades

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( nargin() < 3 ), ang_step = 10; end
			if( nargin() < 4 ), ang_win = 20; end

			if( exist( [folder,'/MemBias.mat'], 'file' ) == 2 )
				load( [folder,'/MemBias.mat'] );
			else
				MemBias = [];
				refinedFolders = ToolKit.ListFolders(folder);
				for( iRefined = 1 : size(refinedFolders,1) )
					refinedFolder = ToolKit.RMEndSpaces( refinedFolders(iRefined,:) );
					mem = BlocksAnalyzer( 'MemBlock', ToolKit.ListMatFiles(refinedFolder) );
					MemBias(end+1).name = refinedFolder( find( refinedFolder == '\', 1, 'last' ) + 1 : end );
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

				save( [folder,'/MemBias.mat'], 'MemBias' );
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
			figName = [ subject,' Breaks After Fp On Before Candidates On' ];
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
			errorbar( 1, mean(left), std(left)/2, std(left)/2, 'color', 'g' );
			text( 1, 0, 'Left', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(right), 0.5, 'r' );
			errorbar( 2, mean(right), std(right)/2, std(right)/2, 'color', 'r' );
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
			if( strcmpi( subject, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( subject, 'datou' ) )
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Breaks After Cue On (Population)' ] );
			
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Breaks After Cue On (Significance)' ] );

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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Break Ratio to All Trials After Cue On (Ratio)' ] );

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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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
			if( strcmpi( subject, 'abao' ) )
				tBound = 0.3;
			elseif( strcmpi( subject, 'datou' ) )
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

			set( figure, 'NumberTitle', 'off', 'name', [ subject, ' Error ratio' ] );
			
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
			errorbar( 1, mean(LL), std(LL)/2, std(LL)/2, 'color', 'g' );
			text( 1, 0, 'LL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 2, mean(RR), 0.5, 'r' );
			errorbar( 2, mean(RR), std(RR)/2, std(RR)/2, 'color', 'r' );
			text( 2, 0, 'RR', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12  );
			bar( 3, mean(RL), 0.5, 'g' );
			errorbar( 3, mean(RL), std(RL)/2, std(RL)/2, 'color', 'g' );
			text( 3, 0, 'RL', 'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', 'FontSize', 12 );
			bar( 4, mean(LR), 0.5, 'r' );
			errorbar( 4, mean(LR), std(LR)/2, std(LR)/2, 'color', 'r' );
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

		function ShowParadigm( subject, folder )
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
				eval( [ 'global ', subject, 'MicroSacs;' ] );
				eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
				if( isempty(microSacs) )
					microSacs = MyMethods.LoadMicroSacs( folder );
					eval( [ subject, 'MicroSacs = microSacs;' ] );
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

		function MainSeqDensity(folder)
			% folder:	subject folder

			if( folder(end) == '/' || folder(end) == '\' ), folder(end) = []; end
			if( exist( [folder,'/mainSequence.mat'], 'file' ) == 2 )
				load( [folder,'/mainSequence.mat'] );

			else
				refinedFolders = ToolKit.ListFolders(folder);
				fixational.amplitude = [];
				fixational.peakSpeed = [];
				fixational.angle = [];
				cFixational = 0;
				response.amplitude = [];
				response.peakSpeed = [];
				response.angle = [];
				cResponse = 0;
				breaks.amplitude = [];
				breaks.peakSpeed = [];
				breaks.angle = [];
				cBreaks = 0;
				for( i = 1 : size( refinedFolders, 1 ) )
					ba = BlocksAnalyzer( 'RexBlock', ToolKit.ListMatFiles( ToolKit.RMEndSpaces( refinedFolders(i,:) ) ) );%, DATA_FIELD_FLAG.SACCADES + DATA_FIELD_FLAG.RESPONSE_INDEX );
					fixational.amplitude( end + ba.nTrials * 4 ) = 0;
					fixational.peakSpeed( end + ba.nTrials * 4 ) = 0;
					fixational.angle( end + ba.nTrials * 4 ) = 0;
					response.amplitude( end + ba.nTrials ) = 0;
					response.peakSpeed( end + ba.nTrials ) = 0;
					response.angle( end + ba.nTrials ) = 0;
					breaks.amplitude( end + ba.nFixbreak ) = 0;
					breaks.peakSpeed( end + ba.nFixbreak ) = 0;
					breaks.angle( end + ba.nFixbreak ) = 0;
					for( iBlock = 1 : ba.nBlocks )
						for( iTrial = 1 : ba.blocks(iBlock).nTrials )
							trial = ba.blocks(iBlock).trials(iTrial);
							if( ( trial.type == TRIAL_TYPE_DEF.CORRECT || trial.type == TRIAL_TYPE_DEF.ERROR ) && size(trial.fp,2) == 1 && ~isempty(trial.iResponse1) )
								if( trial.iResponse1 - 1 )
									index = find( [ trial.saccades( 1 : trial.iResponse1-1 ).latency ] - trial.fp.tOn > 0 );% & abs( [trial.saccades(1:trial.iResponse1-1).angle] ) < 90 );
									fixational.amplitude( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).amplitude ];
									fixational.peakSpeed( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).peakSpeed ];
									fixational.angle( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).angle ];
									cFixational = cFixational + size(index,2);
								end
								if( true )%abs([trial.saccades(trial.iResponse1).angle]) < 90 )
									cResponse = cResponse + 1;
									response.amplitude( cResponse ) = trial.saccades(trial.iResponse1).amplitude;
									response.peakSpeed( cResponse ) = trial.saccades(trial.iResponse1).peakSpeed;
									response.angle( cResponse ) = trial.saccades(trial.iResponse1).angle;
								end
							elseif( trial.type == TRIAL_TYPE_DEF.FIXBREAK && size(trial.fp,2) == 1 && trial.fp.tOn > 0 )
								[ tBreak, breakSac ] = trial.GetBreak();
								if( tBreak < 0 || isempty(breakSac.latency) ) continue; end
								index = find( [ trial.saccades.latency ] < breakSac.latency & [trial.saccades.latency] > trial.fp.tOn );% & abs( [trial.saccades.angle] ) > 90 );
								if( ~isempty(index) )
									fixational.amplitude( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).amplitude ];
									fixational.peakSpeed( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).peakSpeed ];
									fixational.angle( cFixational+1 : cFixational + size(index,2) ) = [ trial.saccades(index).angle ];
									cFixational = cFixational + size(index,2);
								end
								if( true )%abs( breakSac.angle ) > 90 )
									cBreaks = cBreaks + 1;
									breaks.amplitude( cBreaks ) = breakSac.amplitude;
									breaks.peakSpeed( cBreaks ) = breakSac.peakSpeed;
									breaks.angle( cBreaks ) = breakSac.angle;
								end
							end
						end
					end
					fixational.amplitude( cFixational+1 : end ) = [];
					fixational.peakSpeed( cFixational+1 : end ) = [];
					fixational.angle( cFixational+1 : end ) = [];
					response.amplitude( cResponse+1 : end ) = [];
					response.peakSpeed( cResponse+1 : end ) = [];
					response.angle( cResponse+1 : end ) = [];
					breaks.amplitude( cBreaks+1 : end ) = [];
					breaks.peakSpeed( cBreaks+1 : end ) = [];
					breaks.angle( cBreaks+1 : end ) = [];
				end
				mainSequence.fixational = fixational;
				mainSequence.response = response;
				mainSequence.breaks = breaks;
				save( [ folder, '/mainSequence.mat' ], 'mainSequence' );
			end

			LR = 'both';
			% LR = 'left';
			% LR = 'right';
			UD = 'both';
			% UD = 'up';
			% UD = 'down';
			if( strcmpi( LR, 'left' ) )
				mainSequence.fixational.amplitude( abs( mainSequence.fixational.angle ) < 90 ) = [];
				mainSequence.fixational.peakSpeed( abs( mainSequence.fixational.angle ) < 90 ) = [];
				mainSequence.fixational.angle( abs( mainSequence.fixational.angle ) < 90 ) = [];
				mainSequence.response.amplitude( abs( mainSequence.response.angle ) < 90 ) = [];
				mainSequence.response.peakSpeed( abs( mainSequence.response.angle ) < 90 ) = [];
				mainSequence.response.angle( abs( mainSequence.response.angle ) < 90 ) = [];
				mainSequence.breaks.amplitude( abs( mainSequence.breaks.angle ) < 90 ) = [];
				mainSequence.breaks.peakSpeed( abs( mainSequence.breaks.angle ) < 90 ) = [];
				mainSequence.breaks.angle( abs( mainSequence.breaks.angle ) < 90 ) = [];
			elseif( strcmpi( LR, 'right' ) )
				mainSequence.fixational.amplitude( abs( mainSequence.fixational.angle ) > 90 ) = [];
				mainSequence.fixational.peakSpeed( abs( mainSequence.fixational.angle ) > 90 ) = [];
				mainSequence.fixational.angle( abs( mainSequence.fixational.angle ) > 90 ) = [];
				mainSequence.response.amplitude( abs( mainSequence.response.angle ) > 90 ) = [];
				mainSequence.response.peakSpeed( abs( mainSequence.response.angle ) > 90 ) = [];
				mainSequence.response.angle( abs( mainSequence.response.angle ) > 90 ) = [];
				mainSequence.breaks.amplitude( abs( mainSequence.breaks.angle ) > 90 ) = [];
				mainSequence.breaks.peakSpeed( abs( mainSequence.breaks.angle ) > 90 ) = [];
				mainSequence.breaks.angle( abs( mainSequence.breaks.angle ) > 90 ) = [];
			end
			if( strcmpi( UD, 'up' ) )
				mainSequence.fixational.amplitude( mainSequence.fixational.angle < 0 ) = [];
				mainSequence.fixational.peakSpeed( mainSequence.fixational.angle < 0 ) = [];
				mainSequence.fixational.angle( mainSequence.fixational.angle < 0 ) = [];
				mainSequence.response.amplitude( mainSequence.response.angle < 0 ) = [];
				mainSequence.response.peakSpeed( mainSequence.response.angle < 0 ) = [];
				mainSequence.response.angle( mainSequence.response.angle < 0 ) = [];
				mainSequence.breaks.amplitude( mainSequence.breaks.angle < 0 ) = [];
				mainSequence.breaks.peakSpeed( mainSequence.breaks.angle < 0 ) = [];
				mainSequence.breaks.angle( mainSequence.breaks.angle < 0 ) = [];
			elseif( strcmpi( UD, 'down' ) )
				mainSequence.fixational.amplitude( mainSequence.fixational.angle > 0 ) = [];
				mainSequence.fixational.peakSpeed( mainSequence.fixational.angle > 0 ) = [];
				mainSequence.fixational.angle( mainSequence.fixational.angle > 0 ) = [];
				mainSequence.response.amplitude( mainSequence.response.angle > 0 ) = [];
				mainSequence.response.peakSpeed( mainSequence.response.angle > 0 ) = [];
				mainSequence.response.angle( mainSequence.response.angle > 0 ) = [];
				mainSequence.breaks.amplitude( mainSequence.breaks.angle > 0 ) = [];
				mainSequence.breaks.peakSpeed( mainSequence.breaks.angle > 0 ) = [];
				mainSequence.breaks.angle( mainSequence.breaks.angle > 0 ) = [];
			end

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
			set( figure, 'NumberTitle', 'off', 'name', [ LR '_' UD ] );
			fixational = fixational/max(max(fixational));
			response = response/max(max(response));
			breaks = breaks/max(max(breaks));

			red = ones(size(fixational));
			green = ones(size(red));
			blue = ones(size(red));
			
			green = green - fixational;
			blue = blue - fixational;
			
			red = red - response;
			blue = blue - response;
			red = red - breaks;
			blue = blue - breaks;
			
			red(red<0) = 0;
			green(green<0) = 0;
			blue(blue<0) = 0;

			image( edge{2}, edge{1}, cat( 3, red, green, blue ) );
			set( gca, 'yDir', 'normal', 'box', 'off' );
			xlabel( 'Amplitude in logarithm (\circ)', 'FontSize', 12 );
			ylabel( 'Peak Velocity in logarithm ( \circ/s)', 'FontSize', 12 );
			title( 'Main Sequence', 'FontSize', 12 );
		end

		function PolarDirecDist( folder, subject, ampEdges )
			% folder:	subject folder
			% subject:	specify subject
			% ampEdges:	amplitude range for microsaccades; [0,1] by default

			if( nargin() < 2 ), disp( 'Usage: MyMethods.PolarDirecDist( folder, subject, ampEdges = [0,1] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );

			tStart = MyMethods.GetTStart( folder, subject, 'scis' );
			dataBefore = microSacs( [microSacs.latency] - [microSacs.tCue] < 0 & [microSacs.latency] - [microSacs.tCue] > -0.2 );
			dataAfter = microSacs( [microSacs.latency] - [microSacs.tCue] > tStart );

			dataAfter = MyMethods.Get1stAfter( dataAfter, 'tCue', tStart );

			dataBefore = dataBefore( ampEdges(1) <= [dataBefore.amplitude] & [dataBefore.amplitude] < ampEdges(2) );
			dataAfter = dataAfter( ampEdges(1) <= [dataAfter.amplitude] & [dataAfter.amplitude] < ampEdges(2) );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'PolarDirecDist_', subject, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

		 	cueLoc = [dataAfter.cueLoc];
		 	indexAfter = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0 ];
		 	cueLoc = [dataBefore.cueLoc];
		 	indexBefore = [ cueLoc(1,:) < 0; cueLoc(1,:) > 0 ];
		 	% colors = 'grmc';
		 	colors = [ 0 1 0; 1 0 0; 1 0 1; 0 0 0 ];
		 	ang_step = 3;
		 	tStep = 0.05;
		 	ck = ones(1,5)/5;	% convolution kernal
		 	Handles = zeros(1,9);

		 	data = ToolKit.Hist( [ dataBefore.angle ], -181:2:181, false );
		 	data = conv( [ data( end + 1 - (size(ck,2)-1) / 2 : end ), data, data( 1 : (size(ck,2)-1) / 2 ) ], ck, 'same' );
			data = data( (size(ck,2)-1) / 2 + 1 : end - (size(ck,2)-1) / 2 );
		 	Handles(1) = polar( (-180:2:180)/180*pi, data/sum(data) );
		 	set( Handles(1), 'color', colors(4,:), 'LineWidth', 3, 'DisplayName', 'Before Cue' );
		 	hold on;

		 	for( i = 1 : 2 )
		 		for( j = 4 : -1 : 1 )	% every 50ms, 400ms in total
		 			timeIndex = tStart + 0.100*(j-1) <= [dataAfter.latency] - [dataAfter.tCue] & [dataAfter.latency] - [dataAfter.tCue] < tStart + 0.100*j;
			 		data = ToolKit.Hist( [ dataAfter( indexAfter(i,:) & timeIndex ).angle ], -181:2:181, false );
			 		data = conv( [ data( end + 1 - (size(ck,2)-1) / 2 : end ), data, data( 1 : (size(ck,2)-1) / 2 ) ], ck, 'same' );
			 		data = data( (size(ck,2)-1) / 2 + 1 : end - (size(ck,2)-1) / 2 );
			 		Handles( (i-1)*4 + j + 1 ) = polar( (-180:2:180)/180*pi, data/sum(data) );
			 		set( Handles( (i-1)*4 + j + 1 ), 'color', colors(i,:) * (j/8+0.5) + 1 * ~colors(i,:) * (4-j)/8, 'LineWidth', 3 );
			 		if( i == 1 )	% cue left
			 			set( Handles( (i-1)*4 + j + 1 ), 'DisplayName', sprintf( 'Cue Left %dth 100ms', j ) );
			 		else 			% cue right
			 			set( Handles( (i-1)*4 + j + 1 ), 'DisplayName', sprintf( 'Cue Right %dth 100ms', j ) );
			 		end
			 		hold on;
			 	end
		 		
		 	end
		 	legend(Handles);
		end

		function MemPolarDirecDist( folder, subject, ampEdges )
			% folder:	subject folder
			% subject:	specify subject
			% ampEdges:	amplitude range for microsaccades; [0,1] by default

			if( nargin() < 2 ), disp( 'Usage: MyMethods.MemPolarDirecDist( folder, subject, ampEdges = [0,5] )' ); return; end
			if( nargin() == 2 ), ampEdges = [0,1]; end
			eval( [ 'global ', subject, 'MicroSacs;' ] );
			eval( [ 'microSacs = ', subject, 'MicroSacs;' ] );
			if( isempty(microSacs) )
				microSacs = MyMethods.LoadMicroSacs( folder );
				eval( [ subject, 'MicroSacs = microSacs;' ] );
			end

			tarLoc = [microSacs.tarLoc];
			microSacs = microSacs( tarLoc(2,:) == 0 );

			tStart = MyMethods.GetTStart( folder, subject, 'mgs' );
			dataBefore = microSacs( [microSacs.latency] - [microSacs.tRf] < 0 & [microSacs.latency] - [microSacs.tRf] > -0.2 );
			dataAfter = microSacs( [microSacs.latency] - [microSacs.tRf] > tStart );

			dataAfter = MyMethods.Get1stAfter( dataAfter, 'tRf', tStart );

			dataBefore = dataBefore( ampEdges(1) <= [dataBefore.amplitude] & [dataBefore.amplitude] < ampEdges(2) );
			dataAfter = dataAfter( ampEdges(1) <= [dataAfter.amplitude] & [dataAfter.amplitude] < ampEdges(2) );

			figure;
			set( gcf, 'NumberTitle', 'off', 'Name', [ 'MemPolarDirecDist_', subject, '_amp[', num2str(ampEdges(1)), ',', num2str(ampEdges(2)), ']' ] );
			pause(0.1);
			jf = get(handle(gcf),'javaframe');
		 	jf.setMaximized(1);

		 	tarLoc = [dataAfter.tarLoc];
		 	indexAfter = [ tarLoc(1,:) < 0 & tarLoc(2,:) == 0; tarLoc(1,:) > 0 & tarLoc(2,:) == 0 ];
		 	tarLoc = [dataBefore.tarLoc];
		 	indexBefore = [ tarLoc(1,:) < 0 & tarLoc(2,:) == 0; tarLoc(1,:) > 0 & tarLoc(2,:) == 0 ];
		 	colors = 'grmc';
		 	ang_step = 3;
		 	for( i = 2 : -1 : 1 )
		 	% 	subplot(2,2,i); hold on;
		 	% 	data = ToolKit.Hist( [ dataAfter(indexAfter(i,:)).angle ], -181.5:3:181.5 );
				% bar( -180:3:180, data/sum(data), 1, colors(i) );
				% data = ToolKit.Hist( [ dataBefore(indexBefore(i,:)).angle ], -181.5:3:181.5 );
				% data = ToolKit.Hist( [ dataBefore.angle ], -181.5:3:181.5 );
				% bar( -180:3:180, data/sum(data), 1, colors(i+2) );
				% set( findobj(gca,'type','patch'), 'FaceAlpha', 0.5 );
		 	% 	set( gca, 'xlim', [-180 180]);%, 'ylim', [0 150] );
		 		
		 		% subplot(2,2,3);
		 		data = ToolKit.Hist( [ dataAfter(indexAfter(i,:)).angle ], -181:2:181, false );
		 		polar( (-180:2:180)/180*pi, data/sum(data), colors(i) );
		 		hold on;
		 		
		 	end
		 	data = ToolKit.Hist( [ dataBefore(indexBefore(i,:)).angle ], -181:2:181, false );
		 	data = ToolKit.Hist( [ dataBefore.angle ], -181:2:181, false );
		 	polar( (-180:2:180)/180*pi, data/sum(data), colors(4) );
		 	legend( 'left after cue', 'right after cue', 'before cue' );
		end

	end
end