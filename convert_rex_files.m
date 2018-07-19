function convert_rex_files( src_path, dest_path )
	if src_path(end) ~= '/' && src_path(end) ~= '\'
		src_path = [ src_path, '/' ];
	end
	if dest_path(end) ~= '/' && dest_path(end) ~= '\'
		dest_path = [ dest_path, '/' ];
	end
	if exist( dest_path, 'dir' ) ~= 7
		mkdir( dest_path );
	end

	iDay = find( src_path == '/' | src_path == '\', 2, 'last' );
	dayname = src_path( iDay(1)+1 : end-1 );
	
	list = dir( [ src_path, 'calibrate*A' ] );
	set_points = [];
	recorded_points = [];
	if( ~isempty(list) )
		for i = 1 : size(list,1)
			calBlock = CalBlock( [ dayname, list(i).name(1:end-1) ], [ src_path, list(i).name(1:end-1) ], RexBlock.REX_RAW_FILE );
			set_points = [ set_points; calBlock.set_points ];
			recorded_points = [ recorded_points; calBlock.recorded_points ];
			
			disp( [ 'Saving ', dest_path, calBlock.blockName ] );;
			calBlock.SaveData( dest_path, calBlock.blockName );
			calBlock.delete();
		end
		[ set_points, ~, ic ] = unique( set_points, 'rows' );
        points = [];
		for( k = 1 : size(set_points,1) )
			points(k,:) = mean( recorded_points( ic == k, : ), 1 );
		end
		recorded_points = points;
	end

	list = dir(src_path);
	
	for i = 1 : size(list,1)

		if strcmp( list(i).name, '.' ) || strcmp( list(i).name, '..' ) || list(i).name(end) == 'E'
			continue;
		end
		if exist( [ dest_path, dayname, list(i).name(1:end-1), '.mat' ], 'file' ) == 2
			disp( [ 'Already exist ', dest_path, dayname, list(i).name(1:end-1), '.mat' ] );
			continue;
		end

		if ( list(i).isdir )
			if exist( [ dest_path, list(i).name ], 'dir' ) ~= 7
				mkdir( [ dest_path, list(i).name ] );
			end
			convert_rex_files( [ src_path, list(i).name ], [ dest_path, list(i).name ] );
		elseif list(i).name(end) == 'A' && isempty( strfind( lower(list(i).name), 'calibrate' ) ) && list(i).bytes > 1024
			try
				rb = RexBlock( [ dayname, list(i).name(1:end-1) ], [ src_path, list(i).name(1:end-1) ], RexBlock.REX_RAW_FILE, [], { true, set_points, recorded_points } );
				disp( [ 'Saving ', dest_path, rb.blockName ] );
				rb.SaveData( dest_path, rb.blockName );
				rb.delete();
			catch exception
				disp( [ 'Exeption thrown: ', exception.identifier ] );
			end
		end
			

	end
end
%J:\cue_task_data\FromFTP/abao/2011/201108/bzo110815mem3A
%J:\cue_task_data\FromFTP/abao/2011/201110/b111031c1A
%J:\cue_task_data\FromFTP/abao/2011/201110/b111031c13_2A
%J:\cue_task_data\FromFTP/abao/2011/201110/bao111003A