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

Using the Princeton shape benchmark and
Matlab to generate some point clouds. These point clouds can be rotated and zoomed in
Matlab Ref to {https://github.com/shahramg/FLS-Multimedia2022}.

A potential idea for solving this problem is to reduce some useless points in the
point cloud. As we know, humans can only see a 2D picture. In reality, we compress a 3D
object into a 2D image and then transmit it to our eyes. This indicated all points in the
background of a 3D point cloud are redundant. We can disable these points for saving some computing resource. Making some points invisible will also imporve the accurate of the point cloud since some points will be shown in the front because of the gap between two points on the front. 

Apply the Ray tracing (Ray-AABB Intersection Algorithm). Look at 11_07 Presentation.pptx for more details

## 3. Overall Algorithm

1. Eye position

2. Calculate Ray direction 

    Calculate Unit vector from eye to each point in the point cloud

    Scalar quantization (trade off between runtime and accurate)

    Unique ray direction

3. Ray tracing (Ray-AABB Intersection Algorithm):
   
    Calculate the bounding cube (BC) of the point cloud (max and min point)

    Calculate the intersection point(x) of the ray and the surface of the BC

    Extend the ray from human eye to x until it hits a point in the point cloud

    Return if rays beyond BC 

    Return if the ray has penetrated the BC and has not hit any usable point

    Return after hitting the first point

4.	Mark first visitable vertex 

5.	Mark all neighbor of the current vertex ( x <= 6 neighbors)

6.	Loop through all rays 

7.	Generate new point cloud

## 4. Commands

`pointCloudCompression('$PATH_OF_DATASET', 'OUTPUT_FIle', EYE_POSITION)`

`plotPtCld('./OUTPUT_FIle')`

Example:

`pointCloudCompression('~/Datasets/Princeton/db/17/m1740/m1740.off', './pt1741.ptcld', [1 1 1])`

`plotPtCld('./pt1741.ptcld')`

## 5. Potential Problem

The latency of run-time performance.


## 6. Conclusion
This project will deliver a compression algorithm. Part of the input of this algorithm will be a point cloud and eye position. Then this algorithm will calculate all redundant points base on the eye position. This project will use Matlab to demonstrate results. Eye tracking will also be applied in this project. The compression algorithm will be used as an API. When eye movement is detected,  the API will be called and a new 3D point cloud will be generated.
