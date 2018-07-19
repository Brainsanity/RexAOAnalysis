load( '../../Allocentric/WukongChamberDepth.2.0.mat' );

gridDepth = WukongChamberDepth.data;
tmpGrid = gridDepth;	% used to show measured holes depths

% calculate depths for holes not measured
for( m = 2:-1:1 )
	for( n = 1:2 )
		for( i = m : 2 : 17 )
			for( j = n : 2 : 19 )
				if( gridDepth(i,j) == 0 )
					neighbers = gridDepth( i-1 : i+1, j-1 : j+1 );
					gridDepth(i,j) = mean( neighbers( neighbers > 0 ) );
				end
			end
		end
	end
end

% draw the grid and show depths; deeper holes shown in darker color
set( figure, 'NumberTitle', 'off', 'name', 'Grid' );
hold on;
nHoles = 0;
r = 0.45;
r = 0.5;
minDepth = min(min(gridDepth(gridDepth>-1)));
maxDepth = max(max(gridDepth));
for i = -8 : 1 : 8
	for j = -8 : 1 : 8
		if( sqrt( i^2 + j^2 ) <= 8.45 )
			rectangle( 'position', [ (2*i-1)*r (2*j-1)*r 2*r 2*r ], 'Facecolor', ones(1,3) - max( [ 0 ( gridDepth(9-j,i+10) - minDepth ) / ( maxDepth - minDepth ) * 0.9 + 0.1 ] ), 'Curvature', [1 1] );
			% rectangle( 'position', [ (2*i-1)*r (2*j-1)*r 2*r 2*r ], 'Facecolor', 'w', 'Curvature', [1 1] );
			if( ~( tmpGrid(9-j,i+10) > 0 ) )
				text( 2*i*r, 2*j*r, sprintf( '%.2f', gridDepth(9-j,i+10) ), 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'color', 'r' );
			end
			nHoles = nHoles + 1;
		end
	end
end
rectangle( 'position', [ -8.5*2*r -8.5*2*r 17*2*r 17*2*r ], 'Facecolor', 'none', 'EdgeColor', 'r', 'LineStyle', ':', 'Curvature', [1 1] );
plot( 0, 0, 'r+' );
axis equal;
% set( gca, 'visible', 'off' );
set( gca, 'visible', 'on', 'color', get(gcf,'color') );
xlabel('posterior(-) --> anterior(+)');
ylabel('middle(+) --> lateral(-)');
% nHoles

% show measured holes depths and reference lines
for i = -8 : 1 : 8
	plot( [ 2*i*r, 2*i*r ], get(gca,'ylim'), ':', 'color', 'k' );
	plot( get(gca,'xlim'), [ 2*i*r, 2*i*r ], ':', 'color', 'k' );
	for j = -8 : 1 : 8
		if( sqrt( i^2 + j^2 ) <= 8.45 && tmpGrid(9-j,i+10) > 0 )
			text( 2*i*r, 2*j*r, sprintf( '%.2f', tmpGrid(9-j,i+10) ), 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'center', 'color', 'b', 'FontWeight', 'bold' );
		end
	end
end

WukongChamberDepth.data_full = gridDepth;

% return;

set( figure, 'NumberTitle', 'off', 'name', 'GridDepthSurf' );
hold on;
% gridDepth( isnan(gridDepth) ) = -1;
gridDepth( gridDepth == -1 ) = NaN;
surf( -9:9, -8:8, -gridDepth );
xlabel('posterior(-) --> anterior(+)');
ylabel('middle(-) --> lateral(+)');
set(gca,'YDir','reverse');