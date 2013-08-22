function [ tracks adjacency_tracks A ] = simpletracker(points, max_linking_distance, max_gap_closing, debug)
% Jean-Yves Tinevez < jeanyves.tinevez@gmail.com> November 2011 - 2012
%% Parse arguments
if nargin < 4
  debug = false;
end
if nargin < 3
  max_gap_closing = 3;
end
if nargin < 2
  max_linking_distance = Inf;
end
%% Frame to frame linking
if debug
  fprintf('Frame to frame linking.\n');
end
n_slices = numel(points);
current_slice_index = 0;
row_indices = cell(n_slices, 1);
column_indices = cell(n_slices, 1);
unmatched_targets = cell(n_slices, 1);
unmatched_sources = cell(n_slices, 1);
n_cells = cellfun(@(x) size(x, 1), points);
for i = 1 : n_slices-1
  source = points{i};
  target = points{i+1};
  disp([num2str(i) ' Hungarianlinker'])
  % Frame to frame linking
  [target_indices , distances_junk, unmatched_targets{i+1} ] = ...
    hungarianlinker(source, target, max_linking_distance);
  unmatched_sources{i} = find( target_indices == -1 );
  % Prepare holders for links in the sparse matrix
  n_links = sum( target_indices ~= -1 );
  row_indices{i} = NaN(n_links, 1);
  column_indices{i} = NaN(n_links, 1);
  % Put it in the adjacency matrix
  index = 1;
  for j = 1 : numel(target_indices)
    % If we did not find a proper target to link, we skip
    if target_indices(j) == -1
      continue
    end
    % The source line number in the adjacency matrix
    row_indices{i}(index) = current_slice_index + j;
    % The target column number in the adjacency matrix
    column_indices{i}(index) = current_slice_index + n_cells(i) + target_indices(j);
    index = index + 1;
  end
  current_slice_index = current_slice_index + n_cells(i);
end
row_index = vertcat(row_indices{:});
column_index = vertcat(column_indices{:});
link_flag = ones( numel(row_index), 1);
n_total_cells = sum(n_cells);
A = sparse(row_index, column_index, link_flag, n_total_cells, n_total_cells);
if debug
  fprintf('Creating %d links over a total of %d points.\n', numel(link_flag), n_total_cells)
  fprintf('Done.\n')
end
%% Gap closing
if debug
  fprintf('Gap-closing:\n')
end
current_slice_index = 0;
disp('finding targets...')
for i = 1 : n_slices-2
  % Try to find a target in the frames following, starting at i+2, and
  % parsing over the target that are not part in a link already.
  current_target_slice_index = current_slice_index + n_cells(i) + n_cells(i+1);
  for j = i + 2 : min(i +  max_gap_closing, n_slices)
    source = points{i}(unmatched_sources{i}, :);
    target = points{j}(unmatched_targets{j}, :);
    if isempty(source) || isempty(target)
      continue
    end
    target_indices = nearestneighborlinker(source, target, max_linking_distance);
    % Put it in the adjacency matrix
    for k = 1 : numel(target_indices)
      % If we did not find a proper target to link, we skip
      if target_indices(k) == -1
        continue
      end
      if debug
        fprintf('Creating a link between cell %d of frame %d and cell %d of frame %d.\n', ...
          unmatched_sources{i}(k), i, unmatched_targets{j}(target_indices(k)), j);
      end
      % The source line number in the adjacency matrix
      row_index = current_slice_index + unmatched_sources{i}(k);
      % The target column number in the adjacency matrix
      column_index = current_target_slice_index + unmatched_targets{j}(target_indices(k));
      A(row_index, column_index) = 1; %#ok<SPRIX>
    end
    new_links_target =  target_indices ~= -1 ;
    % Make linked sources unavailable for further linking
    unmatched_sources{i}( new_links_target ) = [];
    % Make linked targets unavailable for further linking
    unmatched_targets{j}(target_indices(new_links_target)) = [];
    current_target_slice_index = current_target_slice_index + n_cells(j);
  end
  current_slice_index = current_slice_index + n_cells(i);
end
if debug
  fprintf('Done.\n')
end
%% Parse adjacency matrix to build tracks
if debug
  fprintf('Building tracks:\n')
end
cells_without_source = find(all( A == 0, 1));
n_tracks = numel(cells_without_source);
adjacency_tracks = cell(n_tracks, 1);
for i = 1 : n_tracks
  tmp_holder = NaN(n_total_cells, 1);
  target = cells_without_source(i);
  index = 1;
  while ~isempty(target)
    tmp_holder(index) = target;
    line = full(A(target, :));
    target = find( line, 1, 'first' );
    index = index + 1;
  end
  adjacency_tracks{i} = tmp_holder ( ~isnan(tmp_holder) );
end
%% Reparse adjacency track index to have it right.
% The trouble with the previous track index is that the index in each
% track refers to the index in the adjacency matrix, not the point in
% the original array. We have to reparse it to put it right.
tracks = cell(n_tracks, 1);
for i = 1 : n_tracks
  adjacency_track = adjacency_tracks{i};
  track = NaN(n_slices, 1);
  for j = 1 : numel(adjacency_track)
    cell_index = adjacency_track(j);
    % We must determine the frame this index belong to
    tmp = cell_index;
    frame_index = 1;
    while tmp > 0
      tmp = tmp - n_cells(frame_index);
      frame_index = frame_index + 1;
    end
    frame_index = frame_index - 1;
    in_frame_cell_index = tmp + n_cells(frame_index);
    track(frame_index) = in_frame_cell_index;
  end
  tracks{i} = track;
end
disp('SimpleTracker is done')
end

