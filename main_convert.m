diary log_wukong.txt;
t = clock;
fprintf( '\n\nRun time: %02d.%02d.%4d %02d:%02d:%02d\n', t(2), t(3), t(1), t(4), t(5), round(t(6)) );
try
	convert_rex_files( 'D:\data\DATA From FTP at ION\Data\wukong\','D:\data\cue_task_data\refinedmat\wukong\' );
catch exception
	disp( [ 'Exeption thrown in main_datou.m: ', exception.identifier ] );
	disp( [ 'Exception message: ', exception.message ] );
end
diary off;