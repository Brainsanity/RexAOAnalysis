diary log_wukong_filter.txt
t = clock;
fprintf( '\n\nRun time: %02d.%02d.%4d %02d:%02d:%02d\n', t(2), t(3), t(1), t(4), t(5), round(t(6)) );
WuKongFilter('D:\data\cue_task_data\refinedmat\wukong');
diary off