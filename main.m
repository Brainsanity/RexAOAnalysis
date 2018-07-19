% func = 'ForCalibration';
% func = 'ShowRespSaccades';
% func = 'ShowEyeXChange';
% func = 'ShowEyeTrace';
func = 'AnaActivity';
func = 'VFBlock.ShowRF';
func = 'ReconstructGrid';

switch(func)
	case 'ForCalibration'
		data.fileName = 'E:\Data in BNU\monkeys\WuKong\201601\20160105\calibrate_7X7_0001.mat';
		data.EyeXChann = 'CAI_017';
		data.EyeYChann = 'CAI_018';
		data.EventCodeChann = 'CInPort_003';
		cb = CalBlock(data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ),data,RexBlock.AO_MAT_FILE,1+4+8+16);
		% figure;
		% hold on;
		% plot(cb.set_points(:,1),cb.set_points(:,2),'ro');
		% plot(cb.recorded_points(:,1),cb.recorded_points(:,2),'b.');
		% return;

		figure;
		hold on;		
		set(gca,'xlim',[-25 25],'ylim',[-25 25],'color','k');
		colors = zeros( 7, 7 );
		colors(:) = (0:48) * 100000;
		colors(25) = 254*255*255;
		colors = repmat( [ 'r', 'g', 'b', 'm', 'c', 'w', 'y' ], 7, 1 );
		colors( 2:2:7, : ) = colors( 2:2:7, end:-1:1 );

		calibration = [];
		% calibration = { true, cb.set_points, cb.recorded_points };
		cb2 = RexBlock( data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ), data, RexBlock.AO_MAT_FILE, 1+4+8+16, calibration );
		trials = cb2.trials(1:end);
		fp = [trials.fp];
		[ obj.set_points, ~, index ] = unique( [ fp.x; fp.y ]', 'rows' );
		obj.recorded_points = zeros( size(obj.set_points) );
		for( i = 1 : size(obj.set_points,1) )
			ts = trials( index == i );
			points = zeros( size(ts,2), 2, 100 )*NaN;
			count = 1;
			for( iTrial = 1 : size(ts,2) )
				if( ts(iTrial).type ~= 'c' ) continue; end
				rwtime = ts(iTrial).evnts( 1, ts(iTrial).evnts(2,:) == REX_CODE_MAP.REWARD );
				ind = round( ( rwtime - 50 ) / 1000 * ts(iTrial).a2dRate );	% 100ms before reward
				points( iTrial, 1, : ) = ts(iTrial).eyeTrace.x( ind : ind+99 );
				points( iTrial, 2, : ) = ts(iTrial).eyeTrace.y( ind : ind+99 );
				plot( median(points(iTrial,1,:)), median(points(iTrial,2,:)), 'o', 'color', colors(i), 'MarkerSize', 2+count*1 );
				count = count + 1;
			end
			obj.recorded_points( i, : ) = nanmedian( nanmedian( points, 3 ), 1 );
			pause;
		end
		% plot( obj.recorded_points(:,1), obj.recorded_points(:,2), 'ok' );		% median locations

		return;


	case 'ShowRespSaccades'
		data.fileName = 'E:\Data in BNU\monkeys\WuKong\201512\20151228\visual_045_225_20arrays_rand_50X9_0001.mat';
		data.EyeXChann = 'CAI_017';
		data.EyeYChann = 'CAI_018';
		data.EventCodeChann = 'CInPort_003';
		% calibration = { true, cb.set_points, cb.recorded_points };
		calibration = [];
		rb = RexBlock( data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ), data,RexBlock.AO_MAT_FILE, 1+4+8+16, calibration );

		figure; hold on;
		for( i = 1 : rb.nTrials )
			if( rb.trials(i).type == 'c' && i <= 533 )
		        if( size( rb.trials(i).iResponse1, 2 ) == 1 )
		            termiPoints = rb.trials(i).saccades(rb.trials(i).iResponse1).termiPoints;
		            plot( termiPoints(1,:), termiPoints(2,:), ':', 'color', [ 0 0.4+i/rb.nTrials*0.6 0 ], 'tag', num2str(i) );
		            plot( termiPoints(1,1), termiPoints(2,1), '.', 'color', [ 0 0 0.4+i/rb.nTrials*0.6 ] );
		            plot( termiPoints(1,2), termiPoints(2,2), '.', 'color', [ 0.4+i/rb.nTrials*0.6 0 0 ] );
		        end
			end
		end

		set(gca,'xlim',[-20 20],'ylim',[-20 20])
		axis equal;

		return;

	case 'ShowEyeXChange'
		data.fileName = 'H:\data\20160727\allo_visual_flash_4X4_4X4_0001.mat';
		data.EyeXChann = 'CAI_017';
		data.EyeYChann = 'CAI_018';
		% data.EyeXChann = 'CAI_022';
		% data.EyeYChann = 'CAI_023';
		data.EventCodeChann = 'CInPort_003';
		data.RecordChanns = '017';
		% calibration = { true, cb.set_points, cb.recorded_points };
		calibration = [];
		rb = RexBlock( data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ), data,RexBlock.AO_MAT_FILE, 1+4+8+16, calibration );

		set( figure, 'NumberTitle', 'off', 'name', rb.blockName );
		hold on;
		for( i = 1 : rb.nTrials )
			if( size( rb.trials(i).iResponse1, 2 ) == 1 )
				termiPoints = rb.trials(i).saccades(rb.trials(i).iResponse1).termiPoints;
				s_eyex(i) = termiPoints(1,1);
				plot( i, termiPoints(1,1), 'b.' );	% start x
				plot( i, termiPoints(2,1), 'g.' );	% start y
				plot( i, termiPoints(1,2), 'r.' );	% end x
				plot( i, termiPoints(2,2), 'm.' );	% end y
			end
		end

		legend( 'Start X', 'Start Y', 'End X', 'End Y' );



	case 'ShowEyeTrace'
		figure;
		% iTrial = 324;
		subplot(1,2,1);
		rb.trials(iTrial).PlotEyeTrace(0);
		subplot(1,2,2);
		hold on;
		plot( rb.trials(iTrial).eyeTrace.x, rb.trials(iTrial).eyeTrace.y );
		plot( rb.trials(iTrial).eyeTrace.x(1), rb.trials(iTrial).eyeTrace.y(1), 'ro' );
		if( rb.trials(iTrial).jmp1.x > 0 )
			plot( [2 2 15], [15 2 2 ] ,'k:');
		else
			plot( [-15 -2 -2], [-2 -2 -15] ,'k:');
		end
		axis equal;
		return;


	case 'AnaActivity'
		data.fileName = 'H:\data\20160727\allo_visual_flash_4X4_4X4_0001.mat';
		data.fileName = 'H:\data\20160824\visual_flash_-35_35_8X8_250_0001.mat';
		data.fileName = 'H:\data\20160824\visual_flash_-35_42_-28_28_8X8_250_0002.mat';
		data.fileName = 'H:\data\20160815\allo_visual_flash_4X4_4X4_250_0002.mat';
		data.fileName = 'H:\data\20160824\frame_visual_flash_2X2_8X8_250_0001.mat';
		data.EyeXChann = 'CAI_017';
		data.EyeYChann = 'CAI_018';
		% data.EyeXChann = 'CAI_022';
		% data.EyeYChann = 'CAI_023';
		data.EventCodeChann = 'CInPort_003';
		data.RecordChanns = '017';
		calibration = [];

		vfb = VFBlock( data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ), data,RexBlock.AO_MAT_FILE, 1+4+8+16, calibration );
		vfb.AnaActivity();


	case 'VFBlock.ShowRF'
		data.fileName = 'E:\ION & BNU\data\neurons\2017.06.26\depth28.090. frame_visual_flash_1X3_8X12_250_0002.mat';
		data.EyeXChann = 'CAI_017';
		data.EyeYChann = 'CAI_018';
		% data.EyeXChann = 'CAI_022';
		% data.EyeYChann = 'CAI_023';
		data.EventCodeChann = 'CInPort_003';
		data.RecordChanns = '017';
		calibration = [];

		fvfb = VFBlock( data.fileName( find( data.fileName == '\', 1, 'last' ) + 1 : end - 4 ), data,RexBlock.AO_MAT_FILE, 1+4+8+16, calibration );
		% fvfb.trials(1:29) = [];
		% fvfb.nTrials = fvfb.nTrials - 29;
		fvfb.ShowRF([0 200]);


	case 'ReconstructGrid'
		hold on;
		Y13 = -110;
		Y24 = -34;
		X1 = ( Y13 - RL1.y(1) ) / ( RL1.y(2) - RL1.y(1) ) * ( RL1.x(2) - RL1.x(1) ) + RL1.x(1);
		X2 = ( Y24 - RL1.y(1) ) / ( RL1.y(2) - RL1.y(1) ) * ( RL1.x(2) - RL1.x(1) ) + RL1.x(1);
		X3 = ( Y13 - RL2.y(1) ) / ( RL2.y(2) - RL2.y(1) ) * ( RL2.x(2) - RL2.x(1) ) + RL2.x(1);
		X4 = ( Y24 - RL2.y(1) ) / ( RL2.y(2) - RL2.y(1) ) * ( RL2.x(2) - RL2.x(1) ) + RL2.x(1);
		d = 0.6;
		centX = mean([X1 X4]) + d;	% centX = 3.0197
		centY = mean([Y13 Y24]) + d/(X2-X1)*(Y24-Y13);	% centY = -73.3166
		for( i = 1 : 17 )
			LineWidth = 2;
			if( i == 9 ) LineWidth = 5; end
			plot( [X1 X2] + ([X3 X4] - [X1 X2]) / 16 * (i-1), [Y13 Y24], 'm', 'LineWidth', LineWidth );
			plot( -( [Y13 Y24] - centY ) + centX, ( [X1 X2] + ([X3 X4] - [X1 X2]) / 16 * (i-1) - centX ) + centY, 'm', 'LineWidth', LineWidth );
		end
		r = (X3 - X1) * (Y24 -Y13) / sqrt( (X2 - X1)^2 + (Y24 - Y13)^2 ) / 2;	% r = 23.3
		plot( r * cosd(0:359) + centX, r * sind(0:359) + centY, 'm', 'LineWidth', 2 );
		plot( centX, centY, '*m', 'LineWidth', 5 );

		hold off;

	otherwise
		;
end

return;






x = ones(1,11);
tX = [];
for i = 1:99
	x = [ zeros(1,10), x, zeros(1,10) ];
	for k = ( size(x,2) - 10 ) : -1 : 1
		tX(k) = sum( x( k : k+10 ) );
	end
	x = tX;
end

return;
folders = ToolKit.ListFolders(folder);
types	= { 'calibrate', 'memory', 'nobg', 'dot_r', 'dot_s', 'dot', 'line_r', 'line_s', 'line' };
filters	= { 'calibrate', 'memory', 'nobg', 'dot*r', 'dot*s', 'dot', 'line*r', 'line*s', 'line' };
for( i = 1 : size(folders,1) )
	% try
	% 	rmdir(folders(i,:));
	% catch exception
	% 	disp(exception);
	% end
	% continue;
	% subfolders = ToolKit.ListFolders( folders(i,:) );
	% for( j = 1 : size(subfolders,1) )
	% 	files = ToolKit.ListMatFiles(subfolders(j,:));
	% 	for( k = 1 : size(files,1) )
	% 		system( [ 'move "', files(k,:), '" "', folders(i,:), '"' ] );
	% 	end
	% 	try
	% 		rmdir(subfolders(j,:));
	% 	catch exception
	% 		disp(exception);
	% 	end
	% end
	% continue;
    curFolder = ToolKit.RMEndSpaces( folders(i,:) );
	iSlash = find( curFolder == '\', 1, 'last' );
	for( j = 1 : size(types,2) )		
		files = dir( [ curFolder, '\*', filters{j}, '*.mat' ] );
		if( isempty(files) ) continue; end
		dest_path = [ folder, '_New\', types{j}, curFolder(iSlash:end) ];
		mkdir(dest_path);
		for( k = 1 : size(files,1) )
			system( [ 'move "', curFolder, '\', files(k).name, '" "', dest_path, '"' ] );
		end
	end
end
return;

for( iBlock = sc.nBlocks : -1 : 1 )
	rb = sc.blocks(iBlock);
	left(iBlock).l = 0;
	left(iBlock).r = 0;
	right(iBlock).l = 0;
	right(iBlock).r = 0;
	for i = 2 : rb.nTrials
	    if( rb.trials(i).fp.tOn <= 0 || isempty( rb.trials(i).eyeTrace ) || rb.trials(i-1).type ~= 'c' ) continue; end	    
		t = round( rb.trials(i).fp.tOn * 1000 );
		if( rb.trials(i-1).jmp1.x < 0 )
			left(iBlock).l = left(iBlock).l + sum( rb.trials(i).eyeTrace.x(1:t) < 0 );
			left(iBlock).r = left(iBlock).r + sum( rb.trials(i).eyeTrace.y(1:t) > 0 );
		elseif( rb.trials(i-1).jmp1.x > 0 )
			right(iBlock).l = right(iBlock).l + sum( rb.trials(i).eyeTrace.x(1:t) < 0 );
			right(iBlock).r = right(iBlock).r + sum( rb.trials(i).eyeTrace.y(1:t) > 0 );
		end
	end
end
return;

% ChangeIndex = AbaoChangeIndex2;
% quarter = [ChangeIndex.quarter23];
% data = [quarter.num];
% [data.down]
% hold on; plot( 1:size(ratio,2), [data.down], 'marker', '*' );
% return;

% ChangeIndex = DatouChangeIndex2;
% fds = { 'quarter1', 'quarter2', 'quarter3', 'quarter4', 'quarter12', 'quarter23', 'quarter34', 'quarter41' };
% for( i = 1 : size(ChangeIndex,2) )
% 	for(  j = 1 : 8 )
% 		ChangeIndex(i).(fds{j}).b.up = ChangeIndex(i).(fds{j}).k.up(2);
% 		ChangeIndex(i).(fds{j}).b.down = ChangeIndex(i).(fds{j}).k.down(2);
% 		ChangeIndex(i).(fds{j}).k.up(2) = [];
% 		ChangeIndex(i).(fds{j}).k.down(2) = [];
% 	end
% end
% return;

% function sc = main(folder)
	% cd D:\data\cue_task_refinedmat\abao\cue\trained\2012 
	% folder = uigetdir()
	% cd D:\analysis_pro
	% sc = DrawSaveFigs(folder);

	% for( i = 1 : sc.nBlocks )
	% 	jmp1 = [ sc.blocks(i).trials( [sc.blocks(i).trials.type] == 'c' ).jmp1 ];
	% 	if( ~isempty(jmp1) )
	% 		angs = unique( cart2pol( [jmp1.x], [jmp1.y] ) / pi * 180 );
	% 		angs(angs>0) = [];
	% 		for( j = 1 : size(angs,2) )
	% 			if( isstruct(counter) && ( any( angs(j) == [counter.angle] ) ) ) 
	% 				counter( angs(j) == [counter.angle] ).blocks{end+1,1} = sc.blocks(i).blockName;
	% 			else
	% 				counter(end+1).angle = angs(j);
	% 				counter(end).blocks = { sc.blocks(i).blockName };
	% 			end
	% 		end
	% 		% if( size(angs,2) > 2 )
	% 		% 	multiCounter(end+1).block = sc.blocks(i).blockName;
	% 		% 	multiCounter(end).angles = [angs];
	% 		% end
	% 	end
	% end

	% %disp('waiting...');
	% %pause;
	% angs = [];
	% for( i = 1 : sc.nBlocks )
	% 	angs = unique( [ angs, sc.blocks(i).GetCueAngles() ] );
	% end
	% return;
	% sc.BreakDist( 1, sc.nBlocks, [ angs-1, 181 ] );
	% return;

	% cd D:\data\cue_task_refinedmat\abao\cue\trainning
	% [name, p] = uigetfile();
	% cd D:\analysis_pro
	% sc = SCueBlocksAnalyzer( [p,name] );
	% % return;
	
 %    trials = sc.blocks(1).trials( [sc.blocks(1).trials.type] ~= 'x' );
	% tBreak = trials.GetBreak();
	% cue = [ trials.cue ];

	% size( find( single(tBreak) > [cue.tOn] + single(0.05) & single(tBreak) < [cue.tOn] + single(0.25) ) )
	% size( find( single(tBreak) > [cue.tOff] + single(0.05) & single(tBreak) < [cue.tOff] + single(0.25) ) )
 
	% return;
	% angs = sc.blocks(1).GetCueAngles();
	% cue_angs = unique( angs );
	% sc.BreakDist( 1, 1, [ angs-1, 181 ] );

	% return;
 

	% diary [ folder, '\log.txt' ];
	
	% try
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201201');
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201202');
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201203');
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201204');
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201205');
		% DrawSaveFigs('D:\data\cue_task_refinedmat\abao\cue\trained\2012\201206');
	% catch exception
	% 	disp( [ 'Exeption thrown in main.m: ', exception.identifier ] );
	% 	disp( [ 'Exception message: ', exception.message ] );
	% end
	% diary off;

	% return;

	
	if( folder(end) ~= '/' && folder(end) ~= '\' )
		folder(end+1) = '\';
	end
	fns = ToolKit.ListFolders(folder);

	diary( [ folder, 'log.txt' ] );
	

    groupEdges = { [0,90], [90,180], [-180,-90], [-90,0], [0,180], [90,270], [-180,0], [-90,90] };
    quarters = { 'quarter1', 'quarter2', 'quarter3', 'quarter4', 'quarter12', 'quarter23', 'quarter34', 'quarter41' };
	for( i = 1 : size(fns,1) )
		try
			fn = ToolKit.RMEndSpaces(fns(i,:));
			sc = DrawSaveFigs( fn );
			% continue;
			% fns2 = ls( fns(i,:) );
			% fns2(1:2,:) = [];
			% fns2 = [ repmat( [fns(i,:),'\'], size(fns2,1), 1 ), fns2 ];

			% for( j = 1 : size(fns2,1) )
			% 	DrawSaveFigs( fns2(j,:) );
			% end
			if( ~isempty(sc) | sc.nBlocks ~= 0 )
				% RT(end+1).name = [ 'abao_', fileNames( i, 1 : find( fileNames(i,:) == ' ', 1, 'first' ) - 1 ) ];
				% latency = sc.ReactionTime();
				% RT(end).left = latency(1).rt( 1 : latency(1).cnt );
				% RT(end).right = latency(2).rt( 1 : latency(2).cnt );

				% BreakBeforeCue(end+1).name = [ monkey, '_', fn( find( fn=='\', 1, 'last' ) + 1 : end ) ];
				% BreakBeforeCue(end).angles = sc.BreakBeforeCue();

				% BreakAfterCue(end+1).name = [ monkey, '_', fn( find( fn=='\', 1, 'last' ) + 1 : end ) ];
				% BreakAfterCue(end).angles = sc.BreakAfterCue();

				% ConditionedErrorDirection(end+1).name = [ monkey, '_', fn( find( fn=='\', 1, 'last' ) + 1 : end ) ];
				% ConditionedErrorDirection(end).data = sc.ConditionedErrorDirection();

				nTrials = nTrials + sc.nTrials;
				nCorrect = nCorrect + sc.nCorrect;
				nFixbreak = nFixbreak + sc.nFixbreak;
				ets = [sc.blocks.trials];
				ets = ets( [ets.type] == TRIAL_TYPE_DEF.ERROR );
				index = logical( ones(size(ets)) );
				j1win = 5;
				for( i = 1 : size(ets,2) )
					sac = ets(i).saccades( ets(i).iResponse1 );
					if( ets(i).jmp1.x - j1win < sac.termiPoints(1,2) && sac.termiPoints(1,2) < ets(i).jmp1.x + j1win &&...
						ets(i).jmp1.y - j1win < sac.termiPoints(2,2) && sac.termiPoints(2,2) < ets(i).jmp1.y + j1win )
						index(i) = false;
					end
				end
				ErrorTrials = [ ErrorTrials, ets(index) ];

				% name = ToolKit.RMEndSpaces(fns(i,:));
    %             ChangeIndex1(end+1).name = name( end-5 : end );
    %             ChangeIndex2(end+1).name = name( end-5 : end );
    %             for( iGroup = 8 : -1 : 1 )
    %             	ChangeIndex1(end).ampRange = [0 1];
    %                 ChangeIndex1(end).(quarters{iGroup}) = sc.MicrosacFitting( 1, sc.nBlocks, groupEdges{iGroup}, [0 1] );
    %                 ChangeIndex2(end).ampRange = [0 1.5];
    %                 ChangeIndex2(end).(quarters{iGroup}) = sc.MicrosacFitting( 1, sc.nBlocks, groupEdges{iGroup}, [0 1.5] );
    %             end
            end

		catch exception
			disp( [ 'Exeption thrown in main.m: ', exception.identifier ] );
		 	disp( [ 'Exception message: ', exception.message ] );
		end
	end

	diary off;
% end