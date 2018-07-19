classdef REX_CODE_MAP
	properties (Constant)
		%% codes
		EVENTCODEMIN	= 1000;
		START			= 1001;
		FPON			= 1003;
		GAP1ON			= 1004;
		JMP1ON			= 1005;
		JMP1OFF			= 1006;
		JMP2ON			= 1034;
		JMP2OFF			= 1035;
		RFON			= 1007;
		RFOFF			= 1010;
		RF2ON			= 1047;
		RF2OFF			= 1040;
		CUEON			= 1016;
		CUEOFF			= 1017;
		CUE2ON			= 1018;
		CUE2OFF			= 1019;
		REWARD			= 1012;
		ERROR			= 1013;
		DISABLE			= 1014;
		ABORT			= 1090;
		FIXBREAK		= 1091;
		BADPHOTOCELL	= 1092;
		VF1ON			= 1101;
		VF1OFF			= 1102;
		VF2ON			= 1103;
		VF2OFF			= 1104;
		EVENTCODEMAX	= 1105;

		ARRAYNUM		= 2000;
		ARRAYNUMMAX		= 2500;

		NPATTERNS		= 3000;
		NPATTERNSMAX	= 3032;
		THRESHOLD		= 4000;
		PATRED			= 5000;
		PATREDMAX		= 5255;
		PATGREEN		= 5300;
		PATGREENMAX		= 5555;
		PATBLUE			= 5600;
		PATBLUEMAX		= 5799;	% may overlap with X
		PATXMIN			= 5800;	% may overlap with BLUE
		PATX			= 6000;
		PATXMAX			= 6250;
		PATYMIN			= 6251;
		PATY			= 6500;
		PATYMAX			= 6750;
		PATTERN			= 7000;
		PATTERNMAX		= 7999;
		PATSIZE			= 10000;
		PATSIZEMAX		= 10050;

		%% stimuli indices
		FP		= 1;
		JMP1	= 2;
		JMP2	= 3;
		RF		= 4;
		RF2		= 5;
		CUE		= 6;
		CUE2	= 7;
		VF1		= 8;
		VF2		= 9;
	end

	properties (Constant, Access=private)
		nStimuli	= 9;
	end

	methods ( Access = private )		
		function obj = REX_CODE_MAP()
		end
	end

	methods ( Static )
		function stims = DECODE( codes )
			%% For ZHOU Yang's data:
			%    1. cue2 has no code indicating number of patterns, however there is a THRESHOLD code which can be used
			%       to identify pattern codes
			%    2. pattern codes of fp starting from code 1028 after fpon code, and also no patterns number indicator

			%% for patterns of fp: pattern codes of fp starting from code 1028, and there is no patterns number indicator
			% !!!!!!NOT ALL IN THIS WAY...
			i1028 = find( codes(2,:) == 1028, 1, 'first' );
			ifp = find( codes(2,:) == REX_CODE_MAP.FPON, 1, 'first' );
			hasFpPats = true;
			if( ~isempty(i1028) && ~isempty(ifp) )
				if( i1028 < ifp )	% in case 1028 precedes fp! Weirdo!!!!!!
					tmp = codes(:,ifp);
					codes( :, i1028+1 : ifp ) = codes( :, i1028 : ifp-1 );
					codes(:,i1028 ) = tmp;
				end
				codes( 2, codes(2,:) == 1028 ) = REX_CODE_MAP.NPATTERNS + 1;
				hasFpPats = true;
			end
			
			% for ZHOU Yang's data: cue2
			iCue2 = find( codes(2,:) == REX_CODE_MAP.CUE2ON );
            for( index = iCue2 )
                iNPats = index - 1 + find( codes(2,index:end) == REX_CODE_MAP.NPATTERNS, 1, 'first' );
                iThreshold = index - 1 + find( codes(2,index:end) == REX_CODE_MAP.THRESHOLD, 1, 'first' );
                if( isempty(iNPats) || ~isempty(iThreshold) && iThreshold < iNPats )
                    codes(2,iThreshold) = REX_CODE_MAP.NPATTERNS + 1;
                end
            end

			% find all on codes together with off codes
			index = find( codes( 2,: ) >= REX_CODE_MAP.EVENTCODEMIN & codes( 2,: ) <= REX_CODE_MAP.EVENTCODEMAX );

			stims{REX_CODE_MAP.nStimuli+1} = [];	% the last element can only be assigned with a double value; REALLY WEIRD!!!!!!

			for( iOn = index )
				% switch the on code
				switch( codes(2,iOn) )
					case REX_CODE_MAP.FPON
						if( hasFpPats )
							onCode = REX_CODE_MAP.FPON;		offCode = REX_CODE_MAP.GAP1ON;	stimIndex = REX_CODE_MAP.FP;
						else
							stims{REX_CODE_MAP.FP}(end+1) = REX_CODE_MAP.DefaultStim();
							stims{REX_CODE_MAP.FP}(end).tOn = single( codes(1,iOn) / 1000 * MK_CONSTANTS.TIME_UNIT );
							iOff = find( codes(2,:) == REX_CODE_MAP.GAP1ON, 1, 'first' );
							if( ~isempty(iOff) )
								stims{REX_CODE_MAP.FP}(end).tOff = single( codes(1,iOff) / 1000 * MK_CONSTANTS.TIME_UNIT );
							else
								stims{REX_CODE_MAP.FP}(end).tOff = single( -1 * MK_CONSTANTS.TIME_UNIT );
							end
							continue;	% continue to the next stimulus when no fp patterns codes available
						end
					case REX_CODE_MAP.JMP1ON
						onCode = REX_CODE_MAP.JMP1ON;	offCode = REX_CODE_MAP.JMP1OFF;	stimIndex = REX_CODE_MAP.JMP1;
					case REX_CODE_MAP.JMP2ON
						onCode = REX_CODE_MAP.JMP2ON;	offCode = REX_CODE_MAP.JMP2OFF;	stimIndex = REX_CODE_MAP.JMP2;
					case REX_CODE_MAP.RFON
						onCode = REX_CODE_MAP.RFON;		offCode = REX_CODE_MAP.RFOFF;	stimIndex = REX_CODE_MAP.RF;
					case REX_CODE_MAP.RF2ON
						onCode = REX_CODE_MAP.RF2ON;	offCode = REX_CODE_MAP.RF2OFF;	stimIndex = REX_CODE_MAP.RF2;
					case REX_CODE_MAP.CUEON
						onCode = REX_CODE_MAP.CUEON;	offCode = REX_CODE_MAP.CUEOFF;	stimIndex = REX_CODE_MAP.CUE;
					case REX_CODE_MAP.CUE2ON
						onCode = REX_CODE_MAP.CUE2ON;	offCode = REX_CODE_MAP.CUE2OFF;	stimIndex = REX_CODE_MAP.CUE2;
						% for those have no cue2 pattern codes
						stims{REX_CODE_MAP.CUE2}(end+1) = REX_CODE_MAP.DefaultStim();
						stims{REX_CODE_MAP.CUE2}(end).tOn = single( codes(1,iOn) / 1000 * MK_CONSTANTS.TIME_UNIT );
						iOff = find( codes(2,:) == REX_CODE_MAP.CUE2OFF, 1, 'first' );
						if( ~isempty(iOff) )
							stims{REX_CODE_MAP.CUE2}(end).tOff = single( codes(1,iOff) / 1000 * MK_CONSTANTS.TIME_UNIT );
						else
							stims{REX_CODE_MAP.CUE2}(end).tOff = single( -1 * MK_CONSTANTS.TIME_UNIT );
						end
						continue;

					case REX_CODE_MAP.VF1ON
						onCode = REX_CODE_MAP.VF1ON;	offCode = REX_CODE_MAP.VF1OFF;	stimIndex = REX_CODE_MAP.VF1;
					case REX_CODE_MAP.VF2ON
						onCode = REX_CODE_MAP.VF2ON;	offCode = REX_CODE_MAP.VF2OFF;	stimIndex = REX_CODE_MAP.VF2;
						
					otherwise
						continue;
				end

				% set the stimulus to default value
				stims{stimIndex}(end+1) = REX_CODE_MAP.DefaultStim();

				% set "on time" in milliseconds
				stims{stimIndex}(end).tOn = single( codes(1,iOn) / 1000 * MK_CONSTANTS.TIME_UNIT );

				% set "off time" in milliseconds
				iOff = iOn - 1 + find( codes(2,iOn:end) == offCode, 1, 'first' );
				if( ~isempty(iOff) )
					stims{stimIndex}(end).tOff = single( codes(1,iOff) / 1000 * MK_CONSTANTS.TIME_UNIT );
				else
					stims{stimIndex}(end).tOff = single( -1 * MK_CONSTANTS.TIME_UNIT );
				end

				% find the code indicating the number of patterns
				iNPats = iOn - 1 +...
					find( codes(2,iOn:end) >= REX_CODE_MAP.NPATTERNS & codes(2,iOn:end) < REX_CODE_MAP.NPATTERNSMAX, 1, 'first' );

				if( isempty(iNPats) )
					continue;
				end

				% set number of patterns
				stims{stimIndex}(end).nPats = uint16( codes(2,iNPats) - REX_CODE_MAP.NPATTERNS );

				% find the next patterns number indicator
				iNPatsNext = iNPats +...
					find( codes(2,iNPats+1:end) >= REX_CODE_MAP.NPATTERNS & codes(2,iNPats+1:end) <= REX_CODE_MAP.NPATTERNSMAX, 1, 'first' );
				if( isempty(iNPatsNext) )
					iNPatsNext = size(codes,2);
				end

				%% set patterns
				
				% fields 		= {      'x',		 'y',      'red',    'green',     'blue',   'shape',     'size' };
				% defaults 	= [        0,          0,          0,          0,          0,         0,         -1 ];
				% types 		= {	'single',	'single',	'single',	'single',	'single',	'int16',	'int16' };
				% bases  = [ REX_CODE_MAP.PATX,		REX_CODE_MAP.PATY,			REX_CODE_MAP.PATRED,		REX_CODE_MAP.PATGREEN,...
				% 		   REX_CODE_MAP.PATBLUE, 	REX_CODE_MAP.PATTERN, 		REX_CODE_MAP.PATSIZE ];
				% lowers = [ REX_CODE_MAP.PATXMIN,	REX_CODE_MAP.PATYMIN,		REX_CODE_MAP.PATRED,		REX_CODE_MAP.PATGREEN,...
				% 		   REX_CODE_MAP.PATBLUE,	REX_CODE_MAP.PATTERN,		REX_CODE_MAP.PATSIZE ];
				% uppers = [ REX_CODE_MAP.PATXMAX,	REX_CODE_MAP.PATYMAX,		REX_CODE_MAP.PATREDMAX,		REX_CODE_MAP.PATGREENMAX,...
				% 		   REX_CODE_MAP.PATBLUEMAX,	REX_CODE_MAP.PATTERNMAX,	REX_CODE_MAP.PATSIZEMAX ];
				% nFields = size(fields,2);
				% for( iField = 1:nFields )
				% 	stims{stimIndex}(end).(fields{iField}) = - bases(iField) +...
				% 		codes( 2, iNPats - 1 +...
				% 			find( codes(2,iNPats:iNPatsNext) >= lowers(iField) & codes(2,iNPats:iNPatsNext) <= uppers(iField),...
				% 				stims{stimIndex}(end).nPats, 'first' ) );
				% 	if( isempty( stims{stimIndex}(end).(fields{iField}) ) )
				% 		stims{stimIndex}(end).(fields{iField}) = defaults(iField) * ones( 1, stims{stimIndex}(end).nPats, types{iField} );
				% 	end
				% 	eval( [ 'stims{stimIndex}(end).(fields{iField}) = ', types{iField}, '( stims{stimIndex}(end).(fields{iField}) );' ] );
				% end
				
				fields	= { 'threshold',              'shape',               'x',               'y',               'red',               'green',               'blue',               'size' };
				bases	= [           0, REX_CODE_MAP.PATTERN, REX_CODE_MAP.PATX, REX_CODE_MAP.PATY, REX_CODE_MAP.PATRED, REX_CODE_MAP.PATGREEN, REX_CODE_MAP.PATBLUE, REX_CODE_MAP.PATSIZE ];
				nFields = size(fields,2);
				% iPats = find( REX_CODE_MAP.PATTERN <= codes( 2, iNPats : iNPatsNext ) & codes( 2, iNPats : iNPatsNext ) <= REX_CODE_MAP.PATTERNMAX );
				iProps = find( REX_CODE_MAP.PATRED <= codes( 2, iNPats : iNPatsNext ) & codes( 2, iNPats : iNPatsNext ) <= REX_CODE_MAP.PATSIZEMAX );
				for( iField = 2 : min( [ nFields-1, size(iProps,2) + 1 ] ) )	% some recorded data have no code for size
					% stims{stimIndex}(end).(fields{iField}) = - bases(iField) + codes( 2, iNPats - 1 + iPats + iField - 2 );
					stims{stimIndex}(end).(fields{iField}) = -bases(iField) + codes( 2, iNPats - 1 + iProps(iField-1) );
				end

				stims{stimIndex}(end).x = single( stims{stimIndex}(end).x / 10 );
				stims{stimIndex}(end).y = single( stims{stimIndex}(end).y / 10 );

				codes(2,iNPats) = 0;

			end

			for( i = 1:REX_CODE_MAP.nStimuli )
				if( isempty(stims{i}) )
					stims{i} = REX_CODE_MAP.DefaultStim();
				end
			end

			stims(end) = [];
		end

		function stim = DefaultStim()
			stim.tOn 	= single( -1 * MK_CONSTANTS.TIME_UNIT );
			stim.tOff 	= single( -1 * MK_CONSTANTS.TIME_UNIT );
			stim.nPats	= uint16(0);
			stim.x		= single(0);
			stim.y		= single(0);
			stim.red	= single(0);
			stim.green	= single(0);
			stim.blue	= single(0);
			stim.shape	= int16(0);
			stim.size	= int16(-1);
			
		end
	end


end