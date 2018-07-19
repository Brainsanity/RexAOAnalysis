function SurPeriods = PSMLatency( data, DPeriod, BLPeriod, SearchPeriod, BinSize, pVal, DEBUG )
	%% SurPeriods = PSMLatency( data, DPeriod, BLPeriod, SearchPeriod[, BinSize=2, pVal=0.05, DEBUG=false] );
	%	Using the Poisson Surprise Method (Legendy and Salcman, 1985) to detect elevated activities. Coded by Bin Yang, Oct. 29. 2015.
	%
	%  output:
	%	SurPeriods				2-row array representing periods of "surprising" activities.
	%							The 1st row stores start time points while 2nd end time points (ms).
	%
	%  input:
	%	data					Cell array each element of which is a vector containing all spike time points (ms) of a single trial.
	%	DPeriod					2-element array describing the time period (ms) of the whole input data set, the 1st element for start and 2nd for end.
	%	BLPeriod				2-element array describing the time period (ms) of baseline activities, the 1st element for start and 2nd for end.
	%	SearchPeriod			2-element array describing the time period (ms) to search for "surprising" activities, the 1st element for start and 2nd for end.
	%	BinSize					Size of time bin (ms) for average firing rate assessment; the value is 2ms by default.
	%	pVal					Threshold for the significance level, which makes statistics S = -log(pVal)), where pVal is the probability that the tested period fires
	%							not less than observed number of spikes at a Poisson distribution with the same average firing rate as the baseline activities.
	%							By default, pVal = 0.05 (S = 1.301).
	%	DEBUG					If set true, the analysis results will be shown in figures.

	if( nargin() < 5 || isempty(BinSize) ) BinSize = 2; end
	if( nargin() < 6 || isempty(pVal) ) pVal = 0.05; end
	if( nargin() < 7 || isempty(DEBUG) ) DEBUG = false; end
	if( nargin() < 4 || isempty(data) ) error( 'Usage: PSMLatency( data, DPeriod, BLPeriod, SearchPeriod[, BinSize=2, pVal=0.05, DEBUG=false] )' ); end

	SurPeriods = [];

	% number of trials
	if( iscell(data) ) nTrials = length(data);
	elseif( ~strcmpi( class(data), 'double' ) || ~strcmpi( class(data), 'single' ) ||  length(data) ~= prod(size(data)) )
		error('Input argument "data" must be a cell array or a vector!');
		return;
	else
		nTrials = 1;
		data = {data};
	end

	% fix BLPeriod according to DPeriod if necessary
	if( BLPeriod(1) < DPeriod(1) )	BLPeriod(1) = DPeriod(1); end
	if( BLPeriod(2) > DPeriod(2) )	BLPeriod(2) = DPeriod(2); end
	if( SearchPeriod(1) < DPeriod(1) ) SearchPeriod(1) = DPeriod(1); end
	if( SearchPeriod(2) > DPeriod(2) ) SearchPeriod(2) = DPeriod(2); end
	
	% show figures
	if(DEBUG)		
		subplot(2,1,1); hold on;
		for( i = 1 : length(data) )
			x = zeros( 1, 3*size(data{i},2) );
			x(1:3:end) = data{i};
			x(2:3:end) = data{i};
			x(3:3:end) = NaN;
			y = zeros(size(x));
			y(1:3:end) = 4*i-3;
			y(2:3:end) = 4*i;
			y(3:3:end) = NaN;
			plot( x, y+50, 'k-', 'LineWidth', 1 );
		end
		set( gca, 'xlim', DPeriod, 'ylim', [1 4*i+100], 'ytick', [] );
		subplot(2,1,2); hold on;
		edges = DPeriod(1) : BinSize : DPeriod(2);
		xdata = histc( [data{:}], edges );
		xdata(end) = [];
		bar( ( edges(1:end-1) + edges(2:end) ) / 2, xdata, 1 );
	end


	% concatenate all spike trains together
	data = [data{:}];

	% get average spike counts in a bin of size BinSize based on baseline activities
	% ATTENTION: no need to fit the baseline activities with a Poisson Distribution to get this average value,
	%            since the only parameter of a Poisson Distribution lambda is the mean value of the dataset.
	lambda = sum( BLPeriod(1) <= data & data < BLPeriod(2) ) / ( BLPeriod(2) - BLPeriod(1) ) * BinSize;

	% find the minimal number of spikes in a bin which makes a surprise
	i = 0;
	while(true)
		NThreshold = find( 1 - cdf( 'poiss', i+1 : i+50, lambda ) < pVal, 1, 'first' );
		if( isempty(NThreshold) )	i = i + 50;
		else
			NThreshold = NThreshold + i;
			break;
		end
	end

	% find surprising periods in the searching period
	SearchSpikeCounts = histc( data, SearchPeriod(1) : BinSize : SearchPeriod(2) );
	SearchSpikeCounts(end) = [];
	iBins = find( SearchSpikeCounts > NThreshold );
	if( isempty(iBins) ) return; end
	EndBins = find( iBins(2:end) - iBins(1:end-1) > 1 );
	if( isempty(EndBins) )	SurPeriods = [ iBins(1); iBins(end) ];
	else
		SurPeriods = iBins( [ 1, EndBins+1; EndBins, end ] );
	end

	% gaps shorter than 3 bins between surprising periods are mended, an the surprising periods shorter than 3 bins are removed.
	index = 1;
	for( i = 2 : size(SurPeriods,2) )
		if( SurPeriods(1,i) - SurPeriods(2,index) < 3 )
			SurPeriods(2,index) = SurPeriods(2,i);
		elseif( index+1 ~= i )
			SurPeriods(:,index+1) = SurPeriods(:,i);
			index = index + 1;
		end
	end
	SurPeriods( :, SurPeriods(2,:) - SurPeriods(1,:) < 3 ) = [];

	SurPeriods(1,:) = SearchPeriod(1) + BinSize * ( SurPeriods(1,:) - 1 );
	SurPeriods(2,:) = SearchPeriod(1) + BinSize * SurPeriods(2,:);
	
	if(DEBUG)
		h = plot( reshape( [SurPeriods;NaN*ones(1,size(SurPeriods,2))], 1, [] ), NThreshold*ones(3*size(SurPeriods,2)), 'r-', 'LineWidth', 2 );
		h(2) = plot( BLPeriod, [lambda lambda], 'g-', 'LineWidth', 2 );
		legend( h(1:2), 'Surprising periods with height of threshold', 'Average baseline activity' );
	end
end