# CompressionOfPointClouds

## 1. Introduction

Point cloud is widely used in visualization, VR, AR, and HoloDesk systems. If we
view a 3D model from a point cloud perspective. The model will be viewed as a large
number of vertices. Because the number of vertices is large, so we need to find a way to
minimize these vertices, then the compressed result can be easily transferred and
rendered. This is especially important in the FLSs system, which will significantly reduce
the number of active (turning on) FLSs, save a lot of energy, and even provided a clear
outline of the 3D objects. Therefore, the compression algorithm is the key to solving this
problem. The main purpose of this project is to implement an algorithm that can reduce
the number of points being used in a 3d point cloud and ensures a clear 3D display.

## 2. Related works and potential ideas

Paper[1] has shown a good solution for using the Princeton shape benchmark and
Matlab to generate some point clouds. These point clouds can be rotated and zoomed in
Matlab. This paper also provided some code for generating point clouds, which helps us
to better observe points inside a 3D point cloud.
A potential idea for solving this problem is to reduce some useless points in the
point cloud. As we know, humans can only see a 2D picture. In reality, we compress a 3D
object into a 2D image and then transmit it to our eyes. This indicated all points in the
background of a 3D object are redundant. We can disable these points for saving some
energy or computing resource. For example, many points in figure 2 behind the vehicle
are redundant. In theory, these points should not be visible. In meantime, if we compare
figures 2 and 3 carefully, we will realize that the outline of the car is not clear enough.
This is because the points on the back of the vehicle are also visible in the picture. This
makes the shape of the vehicle more cluttered. If we disable these points, a better 3D
object will be formed. Of course, if we have enough points and all points form a face
without any gaps, then the shape of the object may also be clear enough, but this will
require a large number of points.

## 3. Potential Problem

The latency of run-time performance is unknown, I assume re-compression does not require too much computation.  


## 4. Conclusion

	This project will deliver a compression algorithm. Part of the input of this algorithm will be a fixed point in the 3D world. Then this algorithm will calculate all redundant points in a point cloud and invisible these points. This project will use Matlab to demonstrate results. Eye tracking will also be applied in this project. The compression algorithm will be used as an API. When eye movement is detected,  the API will be called and a new 3D point cloud will be generated.
