function [flag ,tmin] = rayBCIntersection(origin, direction, vmin, vmax)
    if (direction(1) >= 0) 
    	tmin = (vmin(1) - origin(1)) / direction(1);
    	tmax = (vmax(1) - origin(1)) / direction(1);
    else
    	tmin = (vmax(1) - origin(1)) / direction(1);
    	tmax = (vmin(1) - origin(1)) / direction(1);
    end
  
    if (direction(2) >= 0) 
        tymin = (vmin(2) - origin(2)) / direction(2);
        tymax = (vmax(2) - origin(2)) / direction(2);
    else
    	tymin = (vmax(2) - origin(2)) / direction(2);
    	tymax = (vmin(2) - origin(2)) / direction(2);
    end

    if ( (tmin > tymax) || (tymin > tmax) )
        flag = 0;
        tmin = -1;
    	return;
    end
       
    if (tymin > tmin)
        tmin = tymin;
    end
    
	if (tymax < tmax)
        tmax = tymax;
    end
    
	if (direction(3) >= 0)
       tzmin = (vmin(3) - origin(3)) / direction(3);
       tzmax = (vmax(3) - origin(3)) / direction(3);
    else
       tzmin = (vmax(3) - origin(3)) / direction(3);
       tzmax = (vmin(3) - origin(3)) / direction(3);
    end


    if ((tmin > tzmax) || (tzmin > tmax))
        flag = 0;
        tmin = -1;
       return;
    end
    
    if (tzmin > tmin)
        tmin = tzmin;
    end
   
    if (tzmax < tmax)
        tmax = tzmax;
    end
    
      flag = 1;
end
