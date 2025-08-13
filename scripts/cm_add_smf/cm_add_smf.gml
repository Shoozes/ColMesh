// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function cm_add_smf(container, smfmodel, matrix = undefined, singlesided = true, smoothnormals = false, group = CM_GROUP_SOLID)
{
    var n = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]; // Initialize n as array of 3 vectors
    var v = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]; // Initialize v as array of 3 vectors for clarity
    var normalmatrix;
    var models = smfmodel.mBuff;
    var modelNum = array_length(models);
    if (is_array(matrix)) normalmatrix = cm_matrix_transpose(cm_matrix_invert_orientation(matrix));
    // Loop through the loaded information and generate a model
    for (var m = 0; m < modelNum; ++m)
    {
        var mbuff = models[m];
        var mbuff_bytes_per_vertex = 44; // From SMF system macro
        var buffersize = buffer_get_size(mbuff);
        buffer_seek(mbuff, buffer_seek_start, 0);
        repeat (buffersize / mbuff_bytes_per_vertex) div 3
        {
            for (var i = 0; i < 3; ++i)
            {
                // Read position
                v[i][0] = buffer_read(mbuff, buffer_f32);
                v[i][1] = buffer_read(mbuff, buffer_f32);
                v[i][2] = buffer_read(mbuff, buffer_f32);
                if (is_array(matrix)) v[i] = matrix_transform_vertex(matrix, v[i][0], v[i][1], v[i][2]);
                
                var bytes_read = 12; // Bytes for position (3 * 4)
                
                if (smoothnormals)
                {
                    // Read per-vertex normal
                    n[i][0] = buffer_read(mbuff, buffer_f32);
                    n[i][1] = buffer_read(mbuff, buffer_f32);
                    n[i][2] = buffer_read(mbuff, buffer_f32);
                    if (is_array(matrix)) n[i] = matrix_transform_vertex(normalmatrix, n[i][0], n[i][1], n[i][2], 0);
                    bytes_read += 12; // Add bytes for normal (3 * 4)
                }
                
                // Skip remaining bytes in the vertex to align to next
                buffer_seek(mbuff, buffer_seek_relative, mbuff_bytes_per_vertex - bytes_read);
            }
            
            if (!smoothnormals)
            {
                // Compute flat normal for the triangle using cross product
                var V1 = [v[1][0] - v[0][0], v[1][1] - v[0][1], v[1][2] - v[0][2]];
                var V2 = [v[2][0] - v[0][0], v[2][1] - v[0][1], v[2][2] - v[0][2]];
                var Nx = V1[1] * V2[2] - V1[2] * V2[1];
                var Ny = V1[2] * V2[0] - V1[0] * V2[2];
                var Nz = V1[0] * V2[1] - V1[1] * V2[0];
                var len = sqrt(Nx * Nx + Ny * Ny + Nz * Nz);
                var N = (len > 0) ? [Nx / len, Ny / len, Nz / len] : [0, 0, 1]; // Fallback to up vector if degenerate
                n[0] = N;
                n[1] = N;
                n[2] = N;
            }
            
            // Add the triangle to the container
            cm_add(container, cm_triangle(singlesided, v[0][0], v[0][1], v[0][2], v[1][0], v[1][1], v[1][2], v[2][0], v[2][1], v[2][2], n[0], n[1], n[2], group));
        }
    }
    cm_debug_message("Script cm_add_smf: Successfully added SMF model to colmesh");
    return container;

}
