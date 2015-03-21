

%%

n = 12; % number of partitions in each dimension.
[X,Y] = meshgrid(linspace(0,1,2*n+1));
L = (40/51/0.9)*membrane(1,n);
surf(X,Y,L);
colormap pink;
set(gca,'dataAspectRatio', [1 1 1]);

faces   = delaunay(X,Y);
patches = trisurf(faces,X,Y,L);
set(gca,'dataAspectRatio', [1 1 1]);

vertices = get(patches,'vertices');
facets = vertices';
facets = reshape(facets(:,faces'), 3, 3, []);

% SQUEEZE compacts empty dimensions.
edge1 = squeeze(facets(:,2,:) - facets(:,1,:));
edge2 = squeeze(facets(:,3,:) - facets(:,1,:));
normals = edge1([2 3 1],:) .* edge2([3 1 2],:)...
        - edge2([2 3 1],:) .* edge1([3 1 2],:);
normals = bsxfun(@times,...
  normals, 1 ./ sqrt(sum(normals .* normals, 1)));

meanNormal = zeros(3,length(vertices)); % pre-allocate memory.
for k = 1:length(vertices)
  % Find all faces shared by a vertex
  [sharedFaces,~] = find(faces == k);
  % Compute the mean normal of all faces shared by a vertex
  meanNormal(:,k) = mean(normals(:,sharedFaces),2);
end
meanNormal = bsxfun(@times, meanNormal,...
  1 ./ sqrt(sum(meanNormal .* meanNormal, 1)));

shellThickness = 0.05;
underVertices  = vertices - shellThickness*meanNormal';

underFaces = delaunay(underVertices(:,1),underVertices(:,2));
trisurf(underFaces,...
   underVertices(:,1),...
   underVertices(:,2),...
   underVertices(:,3));
set(gca,'dataAspectRatio', [1 1 1],...
  'xLim',[0 1],'yLim',[0 1]);


boundaryIndices = ...
 [find(vertices(:,2) == min(vertices(:,2))); % min y
  find(vertices(:,1) == max(vertices(:,1))); % max x
  find(vertices(:,2) == max(vertices(:,2))); % max y
  find(vertices(:,1) == min(vertices(:,1)))];% min x

boundaryIndices = [...
  boundaryIndices(1:floor(end/4-1)); % semi open interval [1, end/4).
  boundaryIndices(floor(end/4+1):floor(end/2));%[end/4, end/2)
  boundaryIndices(floor(end*3/4-1):-1:floor(end/2+1));%[end/2,end*3/4)
  boundaryIndices(end-1:-1:floor(end*3/4+1))]; %[end*3/4, end)

constrainedEdges = [boundaryIndices(1:end-1), boundaryIndices(2:end)];
underFaces = DelaunayTri(...
  [underVertices(:,1),underVertices(:,2)],constrainedEdges);

inside = underFaces.inOutStatus; % 1 = in, 0 = out.
underFaces = underFaces.Triangulation(inside,:);

underFaces = fliplr(underFaces);

trisurf(underFaces,...
   underVertices(:,1),...
   underVertices(:,2),...
   underVertices(:,3));
set(gca,'dataAspectRatio', [1 1 1],...
  'xLim',[0 1],'yLim',[0 1]);

wallVertices = [vertices(boundaryIndices,:);
           underVertices(boundaryIndices,:)];
% Number of wall vertices on each surface (nwv).
nwv          = length(wallVertices)/2;
% Allocate memory for wallFaces.
wallFaces    = zeros(2*(nwv-1),3);
% Define the faces.
for k = 1:nwv-1
  wallFaces(k      ,:) = [k+1  ,k      ,k+nwv];
  wallFaces(k+nwv-1,:) = [k+nwv,k+1+nwv,k+1];
end

trisurf(wallFaces,...
   wallVertices(:,1),...
   wallVertices(:,2),...
   wallVertices(:,3));
set(gca,'dataAspectRatio', [1 1 1],...
  'xLim',[0 1],'yLim',[0 1]);

% Shift indices to concatenate with the original surface.
underFaces = underFaces +   length(vertices);
wallFaces  = wallFaces  + 2*length(vertices);
% Concatenate the results.
shellVertices = [vertices; underVertices; wallVertices];
shellFaces    = [faces;    underFaces;    wallFaces];

minZ = min(shellVertices(:,3));
shellVertices = shellVertices...
  - repmat([0 0 minZ],length(shellVertices),1);

trisurf(shellFaces,...
   shellVertices(:,1),...
   shellVertices(:,2),...
   shellVertices(:,3));
set(gca,'dataAspectRatio', [1 1 1],...
  'xLim',[0 1],'yLim',[0 1]);

%% Draw the membrane:
patch('Vertices',shellVertices,...
    'Faces',shellFaces,...
    'FaceColor','r');
axis tight
view(-51,24)

%%

pts = rand([10000,3]); %Generate a random 10000pts
hold on;
plot3(pts(:,1),pts(:,2),pts(:,3),'b*'); %add points to plot

%%
in = inpolyhedron(shellFaces,shellVertices,pts,'FlipNormals',true);
delete(hLine); %clean up
hold on
plot3(pts(in,1),pts(in,2),pts(in,3),'b*'); %add points to plot
set(hPatch,'FaceAlpha',0.3,...
    'EdgeColor','none'); %make the points inside visible

