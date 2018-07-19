function sc = ana_spatialCue( path, first, last, isSaveFig, isSaveData )
	if nargin == 1
		first = 1;
		last = -1;
		isSaveFig = true;
		isSaveData = false;
	elseif nargin == 2
		last = -1;
		isSaveFig = true;
		isSaveData = false;
	elseif nargin == 3
		isSaveFig = true;
		isSaveData = false;
	elseif nargin == 4
		isSaveData = false;
	elseif nargin ~= 5
		disp('Usage: Ana_SpatialCue( path[, first=1, last=end, isSaveFig=true, isSaveData=false] )');
		return;
	end

	if isempty(first)
		first = 1;
	end
	if isempty(last)
		last = -1;
	end
	if isempty(isSaveFig)
		isSaveFig = true;
	end
	if isempty(isSaveData)
		isSaveData = false;
	end

	if path(end) ~= '\' && path(end) ~= '/'
		path(end+1) = '/';
	end
			
	fileNames = ls( path );
	fileNames(1:2,:) = [];	% remove ./ and ../
	index = [];
	for i = 1 : size( fileNames, 1 )
		tmp = find( fileNames( i, : ) ~= ' ', 1, 'last' );
		if tmp <= 4 || ~strcmp( fileNames( i, tmp-3 : tmp ), '.mat' )
			index = [ index, i ];
		end
	end
	fileNames( index, : ) = [];

	if first < 1
		first = 1;
	elseif first > size( fileNames, 1 )
		first = size( fileNames, 1 );
	end
	if last < 1 || last > size( fileNames, 1 )
		last = size( fileNames, 1 );
	end



	fileNames = [ repmat( path, size( fileNames, 1 ), 1 ), fileNames ];

	sc = SpatialCue( fileNames( first:last, : ), true, isSaveData );

	tmp = path;
	if ~isSaveFig
		tmp = [];
	else
		tmp = [ tmp, 'figures' ];
	end
	% sc.ShowPerformance( tmp );
	% sc.MainSequence( tmp );
	% sc.MainSeqDensity( tmp );
	% sc.ShowTask( tmp );
	% sc.BreakDist( tmp );
	% sc.ErrorRepeat( tmp );
	% sc.ShowImage( 1, path );
	% sc.ShowImage( 2, path );
	% % sc.ShowImage( 3, path );
	% close all;
	% sc.PlotPopVec( 1, tmp );
	% close all;
	% sc.PlotPopVec( 2, tmp );
	% close all;
	% sc.PlotPopVec( 3, tmp );
	% close all;

	nEach = 3;
	nGroups = ceil( sc.nBlocks / nEach );
	for i = 1 : nGroups
		if exist( [path,'BreakDist_AllCues'], 'dir' ) ~= 7
			mkdir( [path,'BreakDist_AllCues'] );
		end
		sc.BreakDist( [path,'BreakDist_AllCues'], i*nEach - nEach + 1, i*nEach  );
		close all;
		if exist( [path,'BreakDist_CueConditioned'], 'dir' ) ~= 7
			mkdir( [path,'BreakDist_CueConditioned'] );
		end
		sc.BreakDist( [path,'BreakDist_CueConditioned'], i*nEach - nEach + 1, i*nEach, 1 );
		close all;
	end
end