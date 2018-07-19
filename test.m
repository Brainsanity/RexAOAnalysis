% figure; hold on;
% for( trial = sc.blocks(5).trials )
% 	if( trial.cue.tOn > 0 )
% 		plot( trial.cue.x, trial.cue.y, '.', 'DisplayName', num2str(trial.trialIndex) );
% 	end
% end

figure; hold on;
plot(0,0);
set(gca,'xlim',[-15,15],'ylim',[-15,15]);
trials = sc.blocks(5).trials( [sc.blocks(5).trials.type] == 'c' );
for( trial = trials )
	plot( trial.saccades(trial.iResponse1).termiPoints(3), trial.saccades(trial.iResponse1).termiPoints(4), '.', 'DisplayName', num2str(trial.trialIndex) );    
	plot( trial.cue.x, trial.cue.y, 'r*', 'Marker', '*', 'MarkerSize', 5 );
	pause(0.01);
    plot( trial.cue.x, trial.cue.y, 'w.' );
end