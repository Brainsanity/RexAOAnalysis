function sc = DrawSaveFigs(folder)
	folder = ToolKit.RMEndSpaces(folder);
	if( folder(end) ~= '/' && folder(end) ~= '\' ), folder(end+1) = '\'; end
	sc = SCueBlocksAnalyzer( ToolKit.ListMatFiles(folder) );

	return;

	% assignin( 'base', 'sc', sc );

	% folder = [ folder, 'figures\break_microsac\quarters\' ];
	folder = [ folder, 'figures\' ];
	try
		% delete( [ folder, '\*' ] );
		% rmdir( folder, 's' );
		% movefile( folder, [ folder(1:end-10), 'quarters\' ] );
		% return;
	catch exception
		disp( [ 'Exeption thrown in DrawSaveFigs.m 12: ', exception.identifier ] );
		disp( [ 'Exception message: ', exception.message ] );
		% return;
	end
	mkdir( folder );

	cue_angs = [];
	for( i = 1 : sc.nBlocks )
		% sc.ShowTask([],i,i);
		% sc.blocks(i).SRTDist();
		% sc.blocks(i).Resp1LocDist(1);
		% sc.blocks(i).BreakDist();
		% Save1();

		angs = sc.blocks(i).GetCueAngles();
		cue_angs = unique( [ cue_angs, angs ] );

		% sc.BreakDist( i, i, [ angs-1, 181 ] );
		% Save1();

		% sc.MicroSacDist( i, i, [ angs-1, 181 ] );
		% Save1();

		% sc.BreakMicrosac( i, i, [ angs-0.1, 181 ] );
		% Save1();
	end

	% sc.ShowTask( [], 1, sc.nBlocks );
	% sc.RepeatDist();
	% sc.MainSequence();
	% sc.MainSeqDensity();
	% sc.ShowPerformance();
	% Save2();

	% sc.BreakDist( 1, sc.nBlocks, [ cue_angs-1, 181 ] );
	% % return;
	% Save2();

	% sc.MicroSacDist( 1, sc.nBlocks, [ cue_angs-1, 181 ] );
	% Save2();

	% sc.BreakMicrosac( 1, sc.nBlocks, [ cue_angs-0.1, 181 ] );
	% Save2();

	% sc.BreakMicrosac( 1, sc.nBlocks, [-90,90], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [90,270], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-180,-90], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-90,0], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [0,90], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [90,180], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [0,180], [0,1] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-180,0], [0,1] );

	% sc.BreakMicrosac( 1, sc.nBlocks, [-90,90], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [90,270], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-180,-90], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-90,0], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [0,90], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [90,180], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [0,180], [0,1.5] );
	% sc.BreakMicrosac( 1, sc.nBlocks, [-180,0], [0,1.5] );
	% Save2();

	% sc.ReactionTime();
	% sc.BreakBeforeCue();
	sc.BreakAfterCue();
	sc.ConditionedErrorDirection();
	Save1();

	return;
	
	subfolders = {'break_microsac\quaters\'};% 'break_dis_dist\', 'break_time_dist\', 'microsaccade\', 'response1_location_distribution\', 'saccade_reaction_time\', 'task\' };
	prefixes   = {'BreakMicroSac_cue['};% 'BreakDist_cue[', 'Break_Distribution', 'MicroSac_cue[', 'response1_location_distribution', 'saccade_reaction_time_distribution', 'Task_blocks[' };

	for( i = 1 : size(subfolders,2) )
		mkdir( [ folder, subfolders{i} ] );
		[ 'move "', folder, prefixes{i} '*.*" "', folder, subfolders{i} '"' ]
		system( [ 'move "', folder, prefixes{i} '*.*" "', folder, subfolders{i} '"' ] );
	end

	function Save1()
		hs = findobj( 'type', 'figure' );
		for( h = hs' )
			saveas( h, [ folder, get(h,'name'), '.bmp' ] );
			saveas( h, [ folder, get(h,'name'), '.fig' ] );
		end
		close all;
		pause(1);
	end

	function Save2()
		hs = findobj( 'type', 'figure' );
		for( h = hs' )
			name = get(h,'name');
			if( any( name == '[' ) )
				name( find( name == '[', 1, 'last' ) + 1 : end ) = [];
				name = [ name, '1,', num2str(sc.nBlocks), ']' ];
			end
			saveas( h, [ folder, name, '.bmp' ] );
			saveas( h, [ folder, name, '.fig' ] );
		end
		close all;
		pause(0.5);
	end
end