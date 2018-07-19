path = 'D:\cue_task_data\converted\abao\cue\trainning\';`
years = ls( path );
years(1:2,:) = [];
for i = 1 : size(years,1)
	months = ls( [ path, years(i,:) ] );
	months(1:2,:) = [];
	for j = 1 : size(months,1)
		sc = Ana_SpatialCue( [ path, years(i,:), '\', months(j,:) ], [], [], true, true );
	end
end

% function tool( sc, path, nGroups, nEach )
% 	for i = 1 : nGroups
% 		if exist( [path,'\BreakDist_AllCues'], 'dir' ) ~= 7
% 			mkdir( [path,'\BreakDist_AllCues'] );
% 		end
% 		sc.BreakDist( [path,'\BreakDist_AllCues'], i*nEach - nEach + 1, i*nEach  );
% 		close all;
% 		if exist( [path,'\BreakDist_CueConditioned'], 'dir' ) ~= 7
% 			mkdir( [path,'\BreakDist_CueConditioned'] );
% 		end
% 		sc.BreakDist( [path,'\BreakDist_CueConditioned'], i*nEach - nEach + 1, i*nEach, 1 );
% 		close all;
% 	end
% end


% for i = 1 : 72
% 	tBreak = sc.blocks(3).trials(index(i)).eventCodes( 1, sc.blocks(3).trials(index(i)).eventCodes(2,:) == CODE_DEF.FIXBREAK );
% 	breakSac = sc.blocks(3).trials(index(i)).saccades;
% 	if isempty(breakSac)
% 		index(i)
% 		continue;
% 	end
% 	breakSac = breakSac( find( [breakSac.latency] < tBreak + 0.05 & [breakSac.latency] > tBreak - 0.1, 1 ) );
% 	p = [ breakSac.termiPoints ];
% 	if size(p,2) ~= 2
% 		p
% 		continue
% 	end
% 	if p(1,2)>0 && p(1,2) < 1.5 && p(2,2) >0 && p(2,2) < 1.5
% 		disp( ['find',num2str(index(i))] );
% 	end
% end


% a=linspace(0,2*pi,100);
% y1=100*sin(a);
% y2=50*cos(a);
% y3=tan(a);
% y4=log(a);
% y=[y1;y2;y3;y4];
% figure
% p=plot(a,y)

% legend(p(1:2),'sin','cos');
% ah=axes('position',get(gca,'position'),...
%             'visible','off');
% legend(p(3:4),'tan','log','location','west');


% for i = 1 : sc.nBlocks
% 	index(i) = sc.blocks(i).GetTFromFp(CODE_DEF.CUE2ON);
% end
% index


% index = [];
% hs = get(gca,'children');
% for i = 1 : size(hs,1)
% 	y = get(hs(i),'ydata');
% 	if y(1) ~= 0
% 		tag = get(hs(i),'tag');
% 		tag( find( tag<'0' | tag>'9' ) ) = [];
% 		index = [index,str2num(tag)];
% 	end
% end