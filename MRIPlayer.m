function MRIPlayer( folder )
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%	Slices: contains original MRI data
	%%		1st dimension: sagital index from left to right (x)
	%%		2nd dimension: coronal index from posterior to anterior (y)
	%%		3rd dimension：horizontal index from bottom to top (z)
	%%
	%%	SectionFuncs: functions for three orthogonal section planes, defined by their normal vectors plus distance from original point
	%%		3X4 double array, each row for the function of one plane
	%%			1st section plane function:		SectionFuncs(1,1) * x + SectionFuncs(1,2) * y + SectionFuncs(1,3) * z + SectionFuncs(1,4) = 0;
	%%			2nd section plane function:		SectionFuncs(2,1) * x + SectionFuncs(2,2) * y + SectionFuncs(2,3) * z + SectionFuncs(2,4) = 0;
	%%			3rd section plane function:		SectionFuncs(3,1) * x + SectionFuncs(3,2) * y + SectionFuncs(3,3) * z + SectionFuncs(3,4) = 0;
	%%
	%%	DisplayAxes: each section plane defined by SectionFuncs is displayed in its own axis parallel to itself, and this variable defines
	%%			   the display axes for each section plane defined by SectionFuncs
	%%		3X9 double array, each row for the display axes of the corresponding section plane in SectionFuncs, and the 1st three columns
	%%	  for the 1st unit vector, the 2nd three for the 2nd unit vector and the last three for the original point
	%%
	%%	HAxes: handles of axes diplaying all three sections
	%%
	%%	LabelColors: color matrix for currently shown labels, each element indicates the color of a corresponding pixel with labels (ranged 0 ~ 256*256*256-1)
	%%	Labels: structure array containing labels
	%%		Labels(i).nPoints		number of points in the i-th label
	%%		Labels(i).points		nX3 array storing coordinates of all points composing the i-th label
	%%		Labels(i).color			1X3 vector indicating color of the i-th label in rgb with range of [0, 255]
	%%	CurrentShownLabels:	index of labels current shown
	%%	CurrentLabel:	index of current label being edited
	%%	CurSubLabel:	current sub-label, nX2 array
	%%  IsEditCurSubLabel:	whether the user is editing the CurSubLabel
	%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%% initialize all variables
	% get Slices
	if( folder(end) ~= '\' && folder(end) ~= '/' )
		folder(end+1) = '/';
	end
	fileLists = ls( [ folder, '*.IMA' ] );
	if( isempty(fileLists) )
		return;
	end
	nSagitals = size(fileLists,1);
	for( iSagital = 1 : nSagitals )
		Slices( nSagitals - iSagital + 1, :, : ) = double( dicomread( [ folder, fileLists(iSagital,:) ] ) );
		% Slices( x, :, : ) = conv2( shiftdim( Slices( x, :, : ), 1 ), ones(3,3)/9, 'same' );
		% Slices( x, 2:end-1, : ) = ( Slices( x, 3:end, : ) - Slices( x, 1:end-2, : ) ) ./ 2;
		% Slices( x, :, 2:end-1 ) = ( Slices( x, :, 3:end ) - Slices( x, :, 1:end-2 ) ) ./ 2;
	end	
	% Slices = Slices / max( Slices(:) ) * 64 * 1;
	Slices( :, end:-1:1, : ) = Slices;


	% initialize SectionFuncs
	SectionFuncs(1,:) = [ 1, 0, 0, -round( size(Slices,1) / 2 ) ];	% sagital
	SectionFuncs(2,:) = [ 0, 1, 0, -round( size(Slices,2) / 2 ) ];	% coronal
	SectionFuncs(3,:) = [ 0, 0, 1, -round( size(Slices,3) / 2 ) ];	% horizontal

	% initialize DisplayAxes
	crossPoint = ( SectionFuncs(:,1:3)^(-1) * (-SectionFuncs(:,4)) )';
	DisplayAxes = [ SectionFuncs( [2 3 1], 1:3 ), SectionFuncs( [3 1 2], 1:3 ), repmat( crossPoint, 3, 1 ) ];

	% initialize Labels
	CurrentShownLabels = [];
	LabelColors = zeros(size(Slices));
	CurSubLabel = [];
	IsEditCurSubLabel = false;
	if( exist( [ folder, 'Labels.mat' ], 'file' ) == 2 )
		load( [ folder, 'Labels.mat' ] );
	end
	if( exist('Labels','var') )
		% Labels.color = [0 255 255];
		ShowLabel( 1 : size( Labels, 2 ) );
		CurrentLabel = size( Labels, 2 ) + 1;
	else
		CurrentLabel = 1;
	    Labels = [];
	end

	% initialize parameters for reconstruct the grid
	IsConstructGrid = false;
	GridCentX = 3.0197;
	GridCentY = -73.3166;
	GridVector = [1 -2.1943];	% direction of a row of holes on the grid
	GridRadius = 23.3;


	% initialize figure
	figure( 'NumberTitle', 'off', 'tag', '0 0 0', 'name', 'MRIPlayer', 'color', 'w',...
			'KeyPressFcn', @seekImage,...
			'WindowButtonDownFcn', @WindowButtonDownFcn,...
			'WindowButtonMotionFcn', @WindowButtonMotionFcn );
	% colormap('gray');
	
	axisLocs = [ 0.05 0.55 0.4 0.4; 0.55 0.55 0.4 0.4; 0.05 0.05 0.4 0.4 ];
	for( i = 3:-1:1 )
		HAxes(i) = axes( 'position', axisLocs(i,:), 'color', 'k', 'XTick', [] );%, 'NextPlot', 'add' );
		PanelLims(i).XLim = [];
		PanelLims(i).YLim = [];
    end
	UpdataFigure();


	function UpdataFigure()
		labels = 'xyz';
		lineColors = 'rgb';
		tags = sscanf( get( gcf, 'tag' ), '%f' )';
		for( i = 1 : 3 )
			[ ~, iLeastVariantCC ] = max( abs( SectionFuncs(i,1:3) * [ 1 0 0; 0 1 0; 0 0 1 ] ) );	% index of the coefficient of which the corresponding dimension is least variant
			iOtherCCs = mod( iLeastVariantCC + [0, 1], 3 ) + 1;	%% following the axes sequence: iLeastVariantCC, iLeastVariantCC+1, iLeastVariantCC+2
			[ X, Y ] = meshgrid( 1 : size(Slices,iOtherCCs(1)), 1 : size(Slices,iOtherCCs(2)) );
            X = X(:);
            Y = Y(:);
            Z = round( ( - X * SectionFuncs(i,iOtherCCs(1)) - Y * SectionFuncs(i,iOtherCCs(2)) - SectionFuncs(i,4) ) / SectionFuncs(i,iLeastVariantCC) );
            
            clear points;
            points( :, [ iOtherCCs iLeastVariantCC ] ) = [ X, Y, Z ];
            points( Z < 1 | Z > size(Slices,iLeastVariantCC), : ) = [];
            
			clear localPoints;
			localPoints(:,2) = round( ( points - repmat( DisplayAxes(i,7:9), size(points,1), 1 ) ) * DisplayAxes(i,4:6)' );
			localPoints(:,1) = round( ( points - repmat( DisplayAxes(i,7:9), size(points,1), 1 ) ) * DisplayAxes(i,1:3)' );

			xMin = min( localPoints(:,1) );
			xMax = max( localPoints(:,1) );
			yMin = min( localPoints(:,2) );
			yMax = max( localPoints(:,2) );

			plane = zeros( xMax-xMin+1, yMax-yMin+1 );
			[X Y]= meshgrid( xMin:xMax, yMin:yMax );
			X = X(:);
			Y = Y(:);
			points = round( repmat( X, 1, 3 ) .* repmat( DisplayAxes(i,1:3), size(X) ) + repmat( Y, 1, 3 ) .* repmat( DisplayAxes(i,4:6), size(Y) ) + repmat( DisplayAxes(i,7:9), size(X) ) );
			X( points(:,1) < 1 | points(:,1) > size(Slices,1), : ) = [];
			Y( points(:,1) < 1 | points(:,1) > size(Slices,1), : ) = [];
			points( points(:,1) < 1 | points(:,1) > size(Slices,1), : ) = [];
			X( points(:,2) < 1 | points(:,2) > size(Slices,2), : ) = [];
			Y( points(:,2) < 1 | points(:,2) > size(Slices,2), : ) = [];
			points( points(:,2) < 1 | points(:,2) > size(Slices,2), : ) = [];
			X( points(:,3) < 1 | points(:,3) > size(Slices,3), : ) = [];
			Y( points(:,3) < 1 | points(:,3) > size(Slices,3), : ) = [];
			points( points(:,3) < 1 | points(:,3) > size(Slices,3), : ) = [];
			
			colors = Slices( ( points(:,3) - 1 ) * size(Slices,1) * size(Slices,2) + ( points(:,2) - 1 ) * size(Slices,1) + points(:,1) );

			plane( ( Y - yMin ) * size(plane,1) + X - xMin + 1 ) = colors;	% image of current section
			plane = plane / max(plane(:)) * 2;
			plane(plane>1) = 1;

            crossPoint = ( SectionFuncs(:,1:3)^(-1) * (-SectionFuncs(:,4)) )';
			LinesCenter = ( crossPoint - DisplayAxes(i,7:9) ) * [ DisplayAxes(i,1:3)', DisplayAxes(i,4:6)' ];
			iLines = mod( i + [0, 1], 3 ) + 1;
			point1 = [-100; 100] * ( SectionFuncs(iLines(2),1:3) * [ DisplayAxes(i,1:3)', DisplayAxes(i,4:6)' ] ) + [ LinesCenter; LinesCenter ];	% point on other section 1
			point2 = [-100; 100] * ( SectionFuncs(iLines(1),1:3) * [ DisplayAxes(i,1:3)', DisplayAxes(i,4:6)' ] ) + [ LinesCenter; LinesCenter ];	% point on other section 2


			% add label
			colors = LabelColors( ( points(:,3) - 1 ) * size(Slices,1) * size(Slices,2) + ( points(:,2) - 1 ) * size(Slices,1) + points(:,1) );
			labelPlane = zeros(size(plane));
			labelPlane( ( Y - yMin ) * size(plane,1) + X - xMin + 1 ) = colors;

			for( iColor = 1 : 3 )
				chromatic{4-iColor} = mod( floor( labelPlane / 256^(iColor-1) ), 256 ) / 255;
				tmpPlane = plane;
				tmpPlane( logical(labelPlane) ) = tmpPlane( logical(labelPlane) ) / 1.4;
				tmpPlane( logical(chromatic{4-iColor}) ) = 0;
				chromatic{4-iColor} = chromatic{4-iColor} + tmpPlane;
			end


			if( i == 2 )
				image( [yMin yMax], [xMin xMax], cat( 3, chromatic{1}, chromatic{2}, chromatic{3} ), 'parent', HAxes(i) );	% x for 1st dimension, y for 3rd dimension
				hold( HAxes(i), 'on' );
				plot( HAxes(i), [ point1(1,2), point1(2,2) ], [ point1(1,1), point1(2,1) ], 'color', lineColors(iLines(1)) );
				plot( HAxes(i), [ point2(1,2), point2(2,2) ], [ point2(1,1), point2(2,1) ], 'color', lineColors(iLines(2)) );
				hold( HAxes(i), 'off' );
			else
				image( [xMin xMax], [yMin yMax], cat( 3, chromatic{1}', chromatic{2}', chromatic{3}' ), 'parent', HAxes(i) );
				hold( HAxes(i), 'on' );
				plot( HAxes(i), [ point1(1,1), point1(2,1) ], [ point1(1,2), point1(2,2) ], 'color', lineColors(iLines(1)) );
				plot( HAxes(i), [ point2(1,1), point2(2,1) ], [ point2(1,2), point2(2,2) ], 'color', lineColors(iLines(2)) );
				hold( HAxes(i), 'off' );
			end

			% image( plane, 'parent', HAxes(i) );
			set( HAxes(i), 'color', 'k', 'YDir', 'normal' );
			axis( HAxes(i), 'equal' );
			title( HAxes(i), [ labels(i), ' >> index: ', num2str(tags(i)) ] );

			if( ~isempty(PanelLims(i).XLim) && ~isempty(PanelLims(i).YLim) )
				set( HAxes(i), 'XLim', PanelLims(i).XLim, 'YLim', PanelLims(i).YLim );
			end			
		end
		if( IsConstructGrid )
			hold( HAxes(i), 'on' );
			vectors = [ GridVector; -GridVector(2), GridVector(1); GridVector ];
			for( i = 1 : 2 )
				dx = GridRadius / norm(vectors(i,:)) * vectors(i,1);
				dy = GridRadius / norm(vectors(i,:)) * vectors(i,2);
				for( j = -8 : 8 )
					LineWidth = 2;
					if( j == 0 ) LineWidth = 5; end
					plot( HAxes(3),...
						[dx -dx] + GridCentX + j * GridRadius/8 / norm(vectors(i+1,:)) * vectors(i+1,1),...
						[dy -dy] + GridCentY + j * GridRadius/8 / norm(vectors(i+1,:)) * vectors(i+1,2),...
						'm', 'LineWidth', LineWidth );

				end
			end
			hold( HAxes(i), 'off' );;
		end
	end


	function AddPoint2Label( point )		
	end


	function ShowLabel( iLabels )
        for( iLabel = iLabels )
            if( Labels(iLabel).nPoints <= 0 ), continue; end
    		points = Labels(iLabel).points( 1 : Labels(iLabel).nPoints, : );
    		index = ( points(:,3) - 1 ) * size(LabelColors,1) * size(LabelColors,2) + ( points(:,2) - 1 ) * size(LabelColors,1) + points(:,1);
        	% LabelColors(index) = Labels(iLabel).color * [ 256*256, 256, 1 ]' + LabelColors(index);
        	% LabelColors(index)
            chromatic = [];
        	for( iColor = 1 : 3 )
				chromatic(:,iColor) = mod( floor( LabelColors(index) / 256^(3-iColor) ), 256 ) + Labels(iLabel).color(iColor);
				chromatic( chromatic(:,iColor) > 255, iColor ) = 255;
			end
			LabelColors(index) = chromatic * [ 256*256, 256, 1 ]';
			CurrentShownLabels = unique( [ CurrentShownLabels, iLabel ] );
        end
	end


	function seekImage( hFig, evnt )
		dim = find( HAxes == gca );
		tags = sscanf( get( gcf, 'tag' ), '%f' )';
		switch evnt.Key
			case 'leftarrow'					
				;% iImage = iImage - 1;
				% RotatePlanesAlong( dim, -1 );
			
			case 'downarrow'
				;% iImage = iImage - 100;
			
			case { 'hyphen', 'subtract' }
				;% iImage = iImage - 1000;
				% ShiftPlane( dim, -1 );
			
			case 'rightarrow'
				;% iImage = iImage + 1;
				% RotatePlanesAlong( dim, 1 );
			
			case 'uparrow'
				;% iImage = iImage + 100;
			
			case { 'equal', 'add' }
				;% iImage = iImage + 1000;
				;% ShiftPlane( dim, 1 );

			case '1'
				if( evnt.Character == '1' )
					RotatePlanesAlong( dim, 0.1 );
				else
					RotatePlanesAlong( dim, -0.1 );
				end

			case '2'
				if( evnt.Character == '2' )
					RotatePlanesAlong( dim, 1 );
				else
					RotatePlanesAlong( dim, -1);
				end

			case '3'
				if( evnt.Character == '3' )
					RotatePlanesAlong( dim, 5 );
				else
					RotatePlanesAlong( dim, -5 );
				end

			case '4'
				if( evnt.Character == '4' )
					ShiftPlane( dim, 0.1 );
					tags(dim) = tags(dim) + 0.1;
				else
					ShiftPlane( dim, -0.1 );
					tags(dim) = tags(dim) - 0.1;
				end

			case '5'
				if( evnt.Character == '5' )
					ShiftPlane( dim, 1 );
					tags(dim) = tags(dim) + 1;
				else
					ShiftPlane( dim, -1 );
					tags(dim) = tags(dim) - 1;
				end

			case '6'
				if( evnt.Character == '6' )
					ShiftPlane( dim, 5 );
					tags(dim) = tags(dim) + 5;
				else
					ShiftPlane( dim,-5 );
					tags(dim) = tags(dim) - 5;
				end

			case '0'
				if( evnt.Character == '0' )		% draw grid
					cent = sscanf( input('center: ','s'), '%f%f' );
					GridCentX = cent(1);
					GridCentY = cent(2);
					GridVector = sscanf( input('vector: ','s'), '%f%f' )';
					IsConstructGrid = true;
				else
					IsConstructGrid = false;
				end

			case 'f'
				for( i = 1 : 3 )
					if( HAxes(i) == gca )
						if( evnt.Character == 'f' )
							PanelLims(i).XLim = get( gca, 'XLim' );
							PanelLims(i).YLim = get( gca, 'YLim' );
						else
							PanelLims(i).XLim = [];
							PanelLims(i).YLim = [];
						end
					end
				end
			
			case 'return'
				;
            
            case { 'l', 'L' }	% switch between edit CurSubLabel or not
            	if( IsEditCurSubLabel )
            		IsEditCurSubLabel = false;                    
	            	disp( 'IsEditCurSubLabel = false' );

                    if( isempty(CurSubLabel) )
                        return;
                    end
	            	CurSubLabel(end+1,:) = CurSubLabel(1,:);
	            	[ X Y ] = meshgrid( floor( min(CurSubLabel(:,1)) ) : ceil( max(CurSubLabel(:,1)) ), floor( min(CurSubLabel(:,2)) ) : ceil( max(CurSubLabel(:,2)) ) );
	            	X = X(:);
	            	Y = Y(:);
	            	in = inpolygon( X, Y, CurSubLabel(:,1), CurSubLabel(:,2) );
	            	CurSubLabel = [ X(in), Y(in) ];

	            	if( Labels(CurrentLabel).nPoints == size( Labels(CurrentLabel).points, 1 ) )
						Labels(CurrentLabel).points = [ Labels(CurrentLabel).points; zeros(1000,3) ];
					end
					nPoints = size( CurSubLabel, 1 );
					if( dim == 2 )	% x for dimension 1, y for dimension 3, however, DisplayAxes(2,1:3) is for dimension 3 and DisplayAxes(2,4:6) is for dimension 1
						Labels(CurrentLabel).points( Labels(CurrentLabel).nPoints + 1 : Labels(CurrentLabel).nPoints + nPoints, : ) = round( repmat( CurSubLabel(:,2), 1, 3 ) .* repmat( DisplayAxes( dim, 1:3 ), nPoints, 1 ) + repmat( CurSubLabel(:,1), 1, 3 ) .* repmat( DisplayAxes( dim, 4:6 ), nPoints, 1 ) + repmat( DisplayAxes( dim, 7:9 ), nPoints, 1 ) );
					else
						Labels(CurrentLabel).points( Labels(CurrentLabel).nPoints + 1 : Labels(CurrentLabel).nPoints + nPoints, : ) = round( repmat( CurSubLabel(:,1), 1, 3 ) .* repmat( DisplayAxes( dim, 1:3 ), nPoints, 1 ) + repmat( CurSubLabel(:,2), 1, 3 ) .* repmat( DisplayAxes( dim, 4:6 ), nPoints, 1 ) + repmat( DisplayAxes( dim, 7:9 ), nPoints, 1 ) );
					end
	            	Labels(CurrentLabel).nPoints = Labels(CurrentLabel).nPoints + nPoints;

	            	ShowLabel(CurrentLabel);	            	
	            	CurSubLabel = [];

	            	handles = guidata(hFig);
	            	if( isfield( handles, 'hMovingLine' ) && ishandle(handles.hMovingLine) )
	            		delete(handles.hMovingLine);
	            	end
	            else
	            	if( CurrentLabel > size( Labels, 2 ) )
	            		name = sscanf( input('label name: ','s'), '%s' );
	            		COLOR = sscanf( input('color: ','s'), '%d' )';
				    	if( ~isempty(name) && size(COLOR,2) == 3 )
					    	Labels(CurrentLabel).name = name;
					    	Labels(CurrentLabel).nPoints = 0;
			    			Labels(CurrentLabel).points = [];
					    	Labels(CurrentLabel).color = COLOR;
					    else
					    	disp('Please input a valid label name and a valid RGB color!');
					    	return;
					    end
					end
	            	IsEditCurSubLabel = true;
	            	disp( 'IsEditCurSubLabel = true' );
	            end

	        case 's'
	        	save( [ folder, 'Labels.mat' ], 'Labels' );

	        case 'd'	% show(display) label or not show(display) label
	        	name = sscanf( input('label name: ','s'), '%s' );
	        	names = {Labels.name};
	        	iLabel = find( cellfun( @(c) strcmp( c, name ), names ) );
	        	if( isempty(iLabel) ), return; end
	        	if( evnt.Character == 'd' )	% 'd' pressed: show(display) label
		        	ShowLabel(iLabel);
		        	CurrentShownLabels = unique( [ CurrentShownLabels, iLabel ] );
		        elseif( evnt.Character == 'D' )	% 'd' + shift pressed: not show(display) label
		        	CurrentShownLabels( CurrentShownLabels == iLabel ) = [];
                    LabelColors(:) = 0;
		        	ShowLabel(CurrentShownLabels);
		        end

		    case 'n'	% new label
		    	name = sscanf( input('label name: ','s'), '%s' );
		    	COLOR = sscanf( input('color: ','s'), '%d' )';
		    	if( ~isempty(name) && size(COLOR,2) == 3 )
		    		if( CurrentLabel == size(Labels,2) )
				    	CurrentLabel = CurrentLabel + 1;
				    end
			    	Labels(CurrentLabel).name = name;
			    	Labels(CurrentLabel).nPoints = 0;
			    	Labels(CurrentLabel).points = [];
			    	Labels(CurrentLabel).color = COLOR;
			    end

	        % case
			
			otherwise
				% fprintf( 'Key Pressed: %s\n', evnt.Key );
				% evnt
				return;
		end

		set( gcf, 'tag', sprintf( '%f ', tags ) );

		if( ~strcmp( evnt.Key, 'l' ) )
			UpdataFigure();
		end
	end

	function WindowButtonDownFcn( hFig, evnt )
		if( strcmp( get( hFig, 'SelectionType' ), 'normal' ) )	% left button
			point = get( gca, 'CurrentPoint' );
			if( IsEditCurSubLabel )
				CurSubLabel = [ CurSubLabel; point(1,1:2) ];
				hold( gca, 'on' );
				plot( CurSubLabel( [ max([1,end-1]) end ], 1 ), CurSubLabel( [ max([1,end-1]) end ], 2 ), 'r' );
				hold( gca, 'off' );
			end
		elseif( strcmp( get( hFig, 'SelectionType' ), 'alt' ) )	% right button
			;%'right'
		else
			;%'wheel'
		end
	end

	function WindowButtonMotionFcn( hFig, evnt )
		if( strcmp( get( gcf, 'SelectionType' ), 'normal' ) )	% left button
			point = get( gca, 'CurrentPoint' );
			if( IsEditCurSubLabel )
				if( ~isempty( CurSubLabel ) )
					handles = guidata(hFig);
					if( isfield( handles, 'hMovingLine' ) && ishandle(handles.hMovingLine) )
						set( handles.hMovingLine, 'XData', [ CurSubLabel( end, 1 ), point(1,1) ], 'YData', [ CurSubLabel( end, 2 ), point(1,2) ] );
					else
						hold( gca, 'on' );
						handles.hMovingLine = plot( [ CurSubLabel( end, 1 ), point(1,1) ], [ CurSubLabel( end, 2 ), point(1,2) ], 'r' );
						hold( gca, 'off' );
						guidata( hFig, handles );						
					end
				end
			end
		end
	end

	function crossPoint =  CrossPoint3Planes( secFuncs )
		%% return the cross point of 3 planes defined by secFuncs, which is a 3X4 array with each row representing a plane
		crossPoint = ( secFuncs(:,1:3)^(-1) * (-secFuncs(:,4)) )';
	end

	function RotatePlanesAlong( dim, angle )
		%% This function rotates the three orthogonal planes defined by SectionFuncs round the norm vector of the dimension defined by dim with degrees defined by angle
		%	input:
		%		SectionFuncs:	variable in parent function, 3X4 array with each row defining a plane
		%		DisplayAxes:	variable in parent function
		%		dim:			the pivot of the rotation is the norm vector of the dimension dim
		%		angle:			the angle for the rotation in degrees
		%	output:
		%		SectionFuncs:	planes functions after rotation

		for( i = 1 : 3 )	% normalization
			SectionFuncs(i,:) = SectionFuncs(i,:) / sqrt( sum( SectionFuncs(i,1:3).^2 ) );
		end

		% shift the unchanged plane to the last one
		SectionFuncs = SectionFuncs( [ dim+1 : end, 1 : dim ], : );
		DisplayAxes = DisplayAxes( [ dim+1 : end, 1 : dim ], : );

		crossPoint = SectionFuncs(:,1:3)^(-1) * (-SectionFuncs(:,4));	% get the cross point of the original three planes

		% in order to remain the display axis for each plane to rotate unchanged relative to the plane, we represent the display axis
		%	  for each plane to rotate in the basis composed by the normal vectors of the other two planes
		%	  1st row: 1st axis for the 1st/2nd plane to rotate
		%	  2nd row: 2nd axis for the 1st/2nd plane to rotate
		%	  3rd row: original point for the 1st/2nd plane to rotate
		axis1 = [ ( reshape( DisplayAxes(1,:), 3, 3 )' - [ 0 0 0; 0 0 0; crossPoint'] ) * SectionFuncs(2,1:3)', ( reshape( DisplayAxes(1,:), 3, 3 )' - [ 0 0 0; 0 0 0; crossPoint'] ) * SectionFuncs(3,1:3)' ];
		axis2 = [ ( reshape( DisplayAxes(2,:), 3, 3 )' - [ 0 0 0; 0 0 0; crossPoint'] ) * SectionFuncs(3,1:3)', ( reshape( DisplayAxes(2,:), 3, 3 )' - [ 0 0 0; 0 0 0; crossPoint'] ) * SectionFuncs(1,1:3)' ];
		% axis1 = [ DisplayAxes(1,1:3) * SectionFuncs(2,1:3)', DisplayAxes(1,1:3) * SectionFuncs(3,1:3)';...	% 1st axis for the 1st plane to rotate
		% 		  DisplayAxes(1,4:6) * SectionFuncs(2,1:3)', DisplayAxes(1,4:6) * SectionFuncs(3,1:3)'];	% 2nd axis for the 1st plane to rotate
		% axis2 = [ DisplayAxes(2,1:3) * SectionFuncs(3,1:3)', DisplayAxes(2,1:3) * SectionFuncs(1,1:3)';...	% 1st axis for the 2nd plane to rotate
		% 		  DisplayAxes(2,4:6) * SectionFuncs(3,1:3)', DisplayAxes(2,4:6) * SectionFuncs(1,1:3)'];	% 2nd axis for the 2nd plane to rotate

		% calculate the normal vectors for the first two planes in SectionFuncs after rotation
		plane1 = cosd(angle) * SectionFuncs(1,1:3) + sind(angle) * SectionFuncs(2,1:3);
		plane1 = plane1 / sqrt( sum( plane1.^2 ) );
		plane2 = cosd(angle) * SectionFuncs(2,1:3) - sind(angle) * SectionFuncs(1,1:3);
		plane2 = plane2 / sqrt( sum( plane2.^2 ) );

		% calculate the remainders for plane1 and plane2		
		plane1(4) = - plane1 * crossPoint;
		plane2(4) = - plane2 * crossPoint;

		SectionFuncs(1,:) = plane1;
		SectionFuncs(2,:) = plane2;

		% update display axes according to the saved representations based on normal vectors
		DisplayAxes(1,1:3) = axis1(1,1) * SectionFuncs(2,1:3) + axis1(1,2) * SectionFuncs(3,1:3);
		DisplayAxes(1,4:6) = axis1(2,1) * SectionFuncs(2,1:3) + axis1(2,2) * SectionFuncs(3,1:3);
		DisplayAxes(1,7:9) = axis1(3,1) * SectionFuncs(2,1:3) + axis1(3,2) * SectionFuncs(3,1:3) + crossPoint';
		DisplayAxes(2,1:3) = axis2(1,1) * SectionFuncs(3,1:3) + axis2(1,2) * SectionFuncs(1,1:3);
		DisplayAxes(2,4:6) = axis2(2,1) * SectionFuncs(3,1:3) + axis2(2,2) * SectionFuncs(1,1:3);
		DisplayAxes(2,7:9) = axis2(3,1) * SectionFuncs(3,1:3) + axis2(3,2) * SectionFuncs(1,1:3) + crossPoint';

		% shift the unchanged plane back to its original place
		SectionFuncs = SectionFuncs( [ end-dim+1 : end, 1 : end-dim ], : );
		DisplayAxes = DisplayAxes( [ end-dim+1 : end, 1 : end-dim ], : );

	end

	function ShiftPlane( dim, distance )
		%% This function shift the plane (defined by planeFunc) by distance along its normal vector
		SectionFuncs(dim,4) = SectionFuncs(dim,4) - distance;
		DisplayAxes(dim,7:9) = DisplayAxes(dim,7:9) + distance * SectionFuncs(dim,1:3);
	end
end