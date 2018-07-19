function mrdr_file2rex_block( src_path, dest_path )
	if src_path(end) ~= '/' && src_path(end) ~= '\'
		src_path = [ src_path, '/' ];
	end
	if dest_path(end) ~= '/' && dest_path(end) ~= '\'
		dest_path = [ dest_path, '/' ];
	end
	if exist( dest_path, 'dir' ) ~= 7
		mkdir( dest_path );
	end
	
	list = dir(src_path);
	
	for i = 1 : size(list,1)

		if strcmp( list(i).name, '.' ) || strcmp( list(i).name, '..' )
			continue;
		end
		% if exist( [ dest_path, list(i).name ], 'file' ) == 2
		% 	disp( [ 'Already exist ', dest_path, list(i).name ] );
		% 	continue;
		% end

		if ( list(i).isdir )
			mrdr_file2rex_block( [ src_path, list(i).name ], [ dest_path, list(i).name ] );
		elseif strcmp( list(i).name(max(1,end-3):end), '.mat' )
			try				
				rb = RexBlock( list(i).name(1:end-4), [ src_path, list(i).name ], RexBlock.MRDR_FILE );
				if( rb.nTrials ~= 0 )
					rb.SaveData( dest_path, list(i).name );
				end
				rb.delete();
			catch exception
				disp( [ 'Exeption thrown in mrdr_file2rex_block.m 33: ', exception.identifier ] );
				disp( [ 'Exception message: ', exception.message ] );
			end
		end
	end

	list = dir(dest_path);
	if( size(list,1) == 2 )
		rmdir(dest_path);
	end
end