%b111031c7.mat  14 cue angle conditions
%b111125c9.mat	!!!!!!
%b111127c13.mat b111127c16.mat b111127c16_2.mat b111127c5.mat

% dataPath = '..\..\cue_task_data\tou';
% fileNames = ls(dataPath);
% fileNames(1:2,:) = [];
% for i = 1 : size( fileNames, 1 )
% 	load( [ dataPath, '\', fileNames(i,:) ] );
% 	disp( [ 'loading ', dataPath, '\', fileNames(i,:) ] );
% 	cb = CueTaskBlock(Trials);
% 	cb.MainSequence();
% 	pause;
% end

% return;

% clear all;
% dataPath = '..\..\cue_task_data\bao';
% fileNames = ls(dataPath);
% fileNames(1:2,:) = [];
% cta_bao = CueTaskAnalyzer( dataPath, fileNames );
% cta_bao.SaveData('data\b_nSaccades&nSaccades2Cue.mat');
% saveas(gcf,'data/v4/abou_msd.fig');
% %cta_bao.PolarPlot( 'data\v4\abao\' );
% save('data\bao_v4.mat');

clear all;
dataPath = '..\..\cue_task_data\tou';
fileNames = ls(dataPath);
fileNames(1:2,:) = [];
cta_tou = CueTaskAnalyzer( dataPath, fileNames );
cta_tou.SaveData('data\d_nSaccades&nSaccades2Cue.mat');
saveas(gcf,'data/v4/datou_msd.fig');
%cta_tou.PolarPlot( 'data\v4\datou\' );
save('data\tou_v4.mat');

%save( ['datou/nSaccades',num2str(i),'.mat'], 'nSaccades' );

% clear all;
% dataPath = '../../cue_task_data/bao/';
% fileNames = ls(dataPath);
% fileNames(1:2,:) = [];
% nSaccades = zeros( 360, 1000, 20 );
% for i = 1 : size(fileNames,1)
% 	if i <= 0
% 		continue;
% 	end
% 	disp( [ 'loading ', dataPath, fileNames(i,:) ] );
% 	load( [ dataPath, fileNames(i,:) ] );
% 	cb = CueTaskBlock(Trials);
% 	cb.Analyse();
% 	if cb.isValid
% 		nSaccades = nSaccades + cb.nSaccades;
% 	end
% 	if mod( i, 50 ) == 0
% 		save( ['abao/nSaccades',num2str(i),'.mat'], 'nSaccades' );
% 	end
% end
% save( ['abao/nSaccades',num2str(i),'.mat'], 'nSaccades' );

% clear all;
% load('abao/nSaccades50.mat');
% load('cueConditions.mat');
% sacs = zeros( 720, 1000, 20 );
% for i = 1 : 20
% 	for j = -179 : 180
% 		row = int32( round( j - cueConditions(i) ) );
% 		if row > 180	% row in [-179,180]
% 			row = row - 360;
% 		elseif row <= -180
% 			row = row + 360;
% 		end
% 		row = row + 180;
% 		sacs( j + 180, :, i ) = nSaccades( row, :, i );
% 		sacs( j + 180 + 360, :, i) = nSaccades( row, :, i);
% 	end
% end

% t = nSaccades(:,:,:);
% nSaccades = sacs(:,:,:);

% s = sum( nSaccades, 2 );
% for i = 1 : 20
% 	figure;
% 	plot( s(:,1,i) ); hold on;
% 	plot( ones(1,2)*cb.cueConditions(i)+180, get(gca,'ylim'), 'r'  );
% end
% for i = 1 : 20
% 	img = zeros(  360 + 360, 1000, 3 );
% 	img(:,:,1) = nSaccades( :, :, i ) * 200;
	
% 	rt = 0 - cueConditions(i);
% 	l_t = 180 - cueConditions(i);
% 	if l_t > 180
% 		l_t = l_t - 360;
% 	end

% 	if cueConditions(i) < -90 || cueConditions(i) > 90
% 		t = rt;
% 		rt = l_t;
% 		l_t = t;
% 	end
% 	rt = rt + 180;
% 	l_t = l_t + 180;

% 	%img( round(rt), :, 2 ) = 255;				
% 	%img( round(l_t), :, 3 ) = 255;

% 	img( round(cueConditions(i)) + 180, :, 3 ) = 255;
% 	img( round(cueConditions(i)) + 180 + 360, :, 3 ) = 255;

% 	img = uint8(img);
% 	figure;
% 	image( img );
% 	pause(0.1);
% 	jf = get(handle(gcf),'javaframe');
%  	jf.setMaximized(1);

% end

% nSaccades = t(:,:,:);
% clear t;