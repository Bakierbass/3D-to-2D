%read image
img = imread('106.jp2');
%Rotation Angles converting this angles from grad to radian 
omega = -0.53451*(pi/200);  
phi = -0.19025*(pi/200);     
kappa = -0.13489*(pi/200);
%focal length (mm)
f = 120;
%rotation matrix formulation
R(1,1) = cos(phi)*cos(kappa) + sin(phi)*sin(omega)*sin(kappa);
R(1,2) = cos(omega)*sin(kappa);
R(1,3) = -sin(phi)*cos(kappa) + cos(phi)*sin(omega)*sin(kappa);
R(2,1) = -cos(phi)*sin(kappa) + sin(phi)*sin(omega)*cos(kappa);
R(2,2) = cos(omega)*cos(kappa);
R(2,3) = sin(phi)*sin(kappa) + cos(phi)*sin(omega)*cos(kappa);
R(3,1) = sin(phi)*cos(omega);
R(3,2) = -sin(omega);
R(3,3) = cos(omega)*cos(phi);
%rotation matrix
Rotation = [R(1,1) R(1,2) R(1,3) 0
            R(2,1) R(2,2) R(2,3) 0
            R(3,1) R(3,2) R(3,3) 0
            0 0 0 1];
%Projection Centers in mm
cx = 497312.996;  
cy = 5419477.065;
cz = 1158.888;
%Translation matrix
Trans = [1 0 0 -cx
         0 1 0 -cy 
         0 0 1 -cz
         0 0 0 1];
%focal matrix
Focal = [-f 0 0 0
         0 -f 0 0
         0 0 1 0];
coor = [497312.615 497319.591 497324.876 497328.801 497322.057 497318.113 497312.615;
        5419964.073 5419956.416 5419961.722 5419964.973 5419972.217 5419968.575 5419964.073;
        311.650 311.650 313.700 311.650 311.650 314.300 311.650;
        1 1 1 1 1 1 1];
%homogeneous coordinates
HC = Focal*Rotation*Trans*coor
%By convention, we specify that given (x’,y’,z’) we can recover
%the 2D point (x,y) as x=x'/z'  y=y'/z'
%from homogeneous to euclidian coordinates

c1x = HC(1,1)/HC(3,1);
c1y = HC(2,1)/HC(3,1);
c2x = HC(1,2)/HC(3,2);
c2y = HC(2,2)/HC(3,2);
c3x = HC(1,3)/HC(3,3);
c3y = HC(2,3)/HC(3,3);
c4x = HC(1,4)/HC(3,4);
c4y = HC(2,4)/HC(3,4);
c5x = HC(1,5)/HC(3,5);
c5y = HC(2,5)/HC(3,5);
c6x = HC(1,6)/HC(3,6);
c6y = HC(2,6)/HC(3,6);
c7x = HC(1,7)/HC(3,7);
c7y = HC(2,7)/HC(3,7);

c2D = [c1x c1y;c2x c2y;c3x c3y;c4x c4y
      c5x c5y;c6x c6y;c7x c7y];
%now we need to these coordinates mm to pixel coordinates
pixelsize = 0.012;
c2Dpixel = c2D/pixelsize;

%Intrinsic parameters: we need to shift the origin
%file coordinates in pixel
ox = 6912;
oy = 3840;
u = ox-c2Dpixel(:,2); 
v = oy+c2Dpixel(:,1); 

imshow(img,[]); hold on;
for i=1:7
    plot(v(i,:),u(i,:), 'r.', 'LineWidth', 5, 'MarkerSize', 10);
end

%find building height:I used relief displacement for building height
du = 160;
dv = 0;

%with dx and dy find the bottom coordinates of building
B(1,:) = (u + du);   
B(2,:) = (v + dv);      
B(3,:) = coor(3,:);

imshow(img,[]); hold on;
plot(B(2,:),B(1,:), 'b.', 'LineWidth', 5, 'MarkerSize', 10);

dxmm = (du * 0.012);
dymm = (dv * 0.012);

%distance between top corner and bottom corner
%length of building object on the photo
d = sqrt((dxmm)^2 + (dymm)^2);

%radial distance
%focal length coordinates in pixel
row_pp = 6912;
col_pp = 3840;

%we mutiplied 0.012 because we need to convert pixel to m
radial_dis = sqrt((row_pp-B(1,2))^2 + (col_pp-B(2,2))^2)*0.012 ;

%flying height 900m
building_height = (900*d)/radial_dis
