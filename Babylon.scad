use <sweep.scad>

module tower(){

  profile_l = 15;
  profile_h = 17;
  profile_slope_factor = 1.1;

  bottom_radius = 300;
  rounds_0 = 41;
  extra_rounds = 3;
  gap = 0.01;
  // Height = profile_h * profile_slope_factor
  // Width = profile_l
  profile_0 = [
             [         0, 0,  -(profile_slope_factor - 1)*profile_h],
             [         0, 0, -profile_h*profile_slope_factor + gap],
             [       -10, 0, -profile_h*profile_slope_factor + gap], // Give profile depth
             [-profile_l-10, 0, 0],
             [-profile_l, 0, 0]
            ];

  // show profile_0
  //path = [translation([0,0,0]),translation([0,10,0])];
  //!sweep(profile_0, path);

  s = 10;
  outshoot = 43;
  scalefac = 1.4;
  profile_1 = [for (v=[0:s:360-s])
                [(bottom_radius-scalefac*profile_l)*cos(v),
                 (bottom_radius-scalefac*profile_l)*sin(v),
                 0]];

  profile_2_a = [for (v=[-10:s:10])
                  [(bottom_radius-scalefac*profile_l)*cos(v) + outshoot*sin((v+10)*180/20),
                   (bottom_radius-scalefac*profile_l)*sin(v),
                    0]];
  profile_2_b = [for (v=[170:s:190])
                  [(bottom_radius-scalefac*profile_l)*cos(v) - outshoot*sin((v-170)*180/20),
                   (bottom_radius-scalefac*profile_l)*sin(v),
                   0]];
  profile_2 = concat(profile_2_a, profile_2_b);

  function move_inwards(v) = bottom_radius*pow((1-(exp(-v*0.0001))),0.5);

  function move_upwards(v) = 23*profile_h*profile_slope_factor*(sin(v/(4*(rounds_0)) - 90) - sin(-90));

  function h(v) = v*(profile_slope_factor*profile_h)/360 + move_upwards(v);
  function r(v) = bottom_radius - move_inwards(v);
  //(bottom_radius-profile_l)*(move_inwards(v+360)-move_inwards(v))/profile_l;

  path_0 = [for (v_0=[360:s:rounds_0*360])
    rotation([0,0,v_0]) *
    translation([move_inwards(v_0) < bottom_radius - 2.5*profile_l ?
                 r(v_0):
                 2.5*profile_l,
                 0,
                 h(v_0)]) *
    scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                 1,
             1+(move_upwards(v_0) - move_upwards(v_0-360))/(profile_slope_factor*profile_h)]) *
    translation([profile_l,0,0])];


  function spiral(rounds, add = 0) =
    [for (v_1=[add:80:rounds*360])
    rotation([0,0,(h(v_1)/(r(v_1)+outshoot))*4*170/(PI)]) *
      translation([0,0,
          h(v_1)]) *
      scaling([move_inwards(v_1) < bottom_radius - 2.5*profile_l ?
          r(v_1)/(bottom_radius-(1.0*profile_l)) :
          2.5*profile_l/(bottom_radius-(1.0*profile_l)),
          move_inwards(v_1) < bottom_radius - 2.5*profile_l ?
          r(v_1)/(bottom_radius-(1.0*profile_l)) :
          2.5*profile_l/(bottom_radius-(1.0*profile_l)),
          1])];

  infillrounds = 1.0;

  //path_1 = spiral(rounds_0 + extra_rounds);
  path_1 = spiral(infillrounds);
  //path_2 = spiral(infillrounds);
  path_2_ab = spiral(rounds_0);
  //path_2_ab = spiral(rounds_0);


  sweep(profile_0, path_0);
  rotate([0,0,-45])
    difference(){
      sweep(profile_1, path_1);
      translate([0,0,-1])
        cylinder(r1=220,r2=144,h=profile_h*3);
    }
  //mirror([1,0,0])
  //rotate([0,0,90])
  //sweep(profile_2, path_2);
  mirror([1,0,0])
  rotate([0,0,90]){
    sweep(profile_2_a, path_2_ab);
    sweep(profile_2_b, path_2_ab);
  }
  mirror([0,0,0])
  rotate([0,0,90+45]){
    sweep(profile_2_a, path_2_ab);
    sweep(profile_2_b, path_2_ab);
  }
}
scale([1,1,4])
tower();
