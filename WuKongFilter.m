function WuKongFilter( src_path )
	if( src_path(end) ~= '/' && src_path(end) ~= '\' )
		src_path = [ src_path, '/' ];
	end
	
	list = dir(src_path);
	
	for( i = 1 : size(list,1) )
		if( strcmp( list(i).name, '.' ) || strcmp( list(i).name, '..' ) )
			continue;
		end
		if( list(i).isdir() )
			WuKongFilter( [ src_path, list(i).name ] );
        else
            disp( [ 'Loading ', src_path, list(i).name, '...' ] );
			load( [ src_path, list(i).name ], 'cue', 'cue2' );
            disp( 'Loaded file successfully!' );
			cue = [cue{:}];
			cue2 = [cue2{:}];
			if( ~isempty(cue) && ~isempty(cue2) && any( [cue.tOn] > 0 ) && all( [cue2.tOn] < 0 ) )
				disp( [ 'Spatial Cue Task found: ', src_path, list(i).name , '!!!!!!' ] );
            end
            clear cue cue2;
		end
	end
end