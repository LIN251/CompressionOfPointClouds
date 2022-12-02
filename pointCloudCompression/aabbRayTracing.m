function output = aabbRayTracing(origin, direction, grid3D, verbose, boxes)
    output = 0;
    [flag, tmin] = rayBCIntersection(origin, direction, grid3D.minBound, grid3D.maxBound);

    if (flag==0)
        output = 0;
        return
    else
        if (tmin<0)
            tmin = 0;
        end;

        start   = origin + tmin*direction;

        x = start(1);
        y = start(2);
        z = start(3);
        if (direction(1)>=0)
            stepX = 1;
        else
            stepX = -1;  
        end;
        
        if (direction(2)>=0)
            stepY = 1;
        else
            stepY = -1;
        end;
        
        if (direction(3)>=0)
            stepZ = 1;
        else
            stepZ = -1;  
        end;
        output = []; 
        while ( (x<=grid3D.nx)&&(x>=1) && (y<=grid3D.ny)&&(y>=1) && (z<=grid3D.nz)&&(z>=1) )
            if (verbose)
                for t=1:size(boxes,1)
                    if (boxes(t,1) == 0 && boxes(t,2) == 0 && boxes(t,3) == 0 &&boxes(t,4) == 0 &&boxes(t,5) == 0 &&boxes(t,6) == 0 )
                        continue
                    end
                    if (x >= boxes(t,1) && x <= boxes(t,4) && y >= boxes(t,2) && y <= boxes(t,5) && z >= boxes(t,3) && z <= boxes(t,6) && ~ismember(t,output))
                        
                        
                        output = [output; t];
                        if size(output,1) >= 4
                            return
                        end
                    end
                end
            end
     
            x = x + direction(1);
            y = y + direction(2);
            z = z + direction(3);
        end;        
     end;
end
