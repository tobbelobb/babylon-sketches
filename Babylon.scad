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
  // show profile
  //path = [translation([0,0,0]),translation([0,10,0])];
  //!sweep(profile_0 , path);

  s = 13;
  outshoot = 45;
  inshoot = 8;
  scalefac = 1.4;
  profile_1 = [for (v=[0:s:360-s])
                [(bottom_radius-scalefac*profile_l)*cos(v),
                 (bottom_radius-scalefac*profile_l)*sin(v),
                 0]];
  profile_2_a = [for (v=[-10:s:10])
                  [(bottom_radius-scalefac*profile_l)*cos(v) + outshoot*sin((v+10)*180/20),
                   (bottom_radius-scalefac*profile_l)*sin(v),
                    0]];
  profile_2_a_inshoot =
    concat([[(bottom_radius-scalefac*profile_l)*cos(-10) - inshoot,
      (bottom_radius-scalefac*profile_l)*sin(-10),
      0]],
      profile_2_a,
      [[(bottom_radius-scalefac*profile_l)*cos(10) - inshoot,
      (bottom_radius-scalefac*profile_l)*sin(10),
      0]]);
  profile_2_b = [for (v=[170:s:190])
                  [(bottom_radius-scalefac*profile_l)*cos(v) - outshoot*sin((v-170)*180/20),
                   (bottom_radius-scalefac*profile_l)*sin(v),
                   0]];
  profile_2_b_inshoot =
    concat([[(bottom_radius-scalefac*profile_l)*cos(190) + inshoot,
      (bottom_radius-scalefac*profile_l)*sin(170),
      0]],
      profile_2_b,
      [[(bottom_radius-scalefac*profile_l)*cos(170) + inshoot,
      (bottom_radius-scalefac*profile_l)*sin(190),
      0]]);
  profile_2 = concat(profile_2_a, profile_2_b);

  function move_inwards(v) = bottom_radius*pow((1-(exp(-v*0.0001))),0.5);

  function move_upwards(v) = 23*profile_h*profile_slope_factor*(sin(v/(4*(rounds_0)) - 90) - sin(-90));

  function h(v) = v*(profile_slope_factor*profile_h)/360 + move_upwards(v);
  //function r(v) = bottom_radius - move_inwards(v) - 10*sin(v*160);
  function r(v) = bottom_radius - move_inwards(v);
  //(bottom_radius-profile_l)*(move_inwards(v+360)-move_inwards(v))/profile_l;

  path_0 = [for (v_0=[360:s:rounds_0*360])
    for(extr = [-s/5:s/20:s/5])
    rotation([0,0,v_0+extr]) *
    translation([move_inwards(v_0+extr) < bottom_radius - 2.5*profile_l ?
                 r(v_0) - 5*sqrt(3*abs(extr)):
                 2.5*profile_l,
                 0,
                 h(v_0+extr)]) *
    scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                 1,
             1+(move_upwards(v_0+extr) - move_upwards(v_0+extr-360))/(profile_slope_factor*profile_h)]) *
    translation([profile_l,0,0])
    //,
    //rotation([0,0,v_0+s/3]) *
    //translation([move_inwards(v_0+s/3) < bottom_radius - 2.5*profile_l ?
    //             r(v_0+s/3):
    //             2.5*profile_l,
    //             0,
    //             h(v_0+s/3)]) *
    //scaling([(move_inwards(v_0+s/3)-move_inwards(v_0+s/3-360))/profile_l,
    //             1,
    //         1+(move_upwards(v_0+s/3) - move_upwards(v_0+s/3-360))/(profile_slope_factor*profile_h)]) *
    //translation([profile_l,0,0])
    ];


  function spiral(rounds, spiraling_factor = 1) =
    [for (v_1=[0:80:rounds*360])
    rotation([0,0,spiraling_factor*(h(v_1)/(r(v_1)+outshoot))*4*170/(PI)]) *
      translation([0,0,
          h(v_1)]) *
      scaling([move_inwards(v_1) < bottom_radius - 2.5*profile_l ?
          r(v_1)/(bottom_radius-(1.0*profile_l)) :
          2.5*profile_l/(bottom_radius-(1.0*profile_l)),
          move_inwards(v_1) < bottom_radius - 2.5*profile_l ?
          r(v_1)/(bottom_radius-(1.0*profile_l)) :
          2.5*profile_l/(bottom_radius-(1.0*profile_l)),
          1])];

  infillrounds = 1.2;

  //path_1 = spiral(rounds_0 + extra_rounds);
  path_1 = spiral(infillrounds);
  //path_2 = spiral(infillrounds);
  path_2_ab = spiral(rounds_0);
  path_2_ab_mirrored = spiral(rounds_0, -1);
  //path_2_ab = spiral(rounds_0);

  //for(v=[0:s:360]){
  //  echo(v)
  //  transform(v, to_3d(profile_2_a));
  //}

  sweep(profile_0, path_0);

  rotate([0,0,-45])
    difference(){
      sweep(profile_1, path_1);
      translate([-6,3,-1])
        cylinder(r1=220,r2=192,h=profile_h*3);
    }

  rotate([0,0,90]){
    sweep(profile_2_a_inshoot, path_2_ab_mirrored);
    sweep(profile_2_b_inshoot, path_2_ab_mirrored);
    //sweep(profile_2, path_2_ab_mirrored);
  }

  rotate([0,0,90+45]){
    sweep(profile_2_a_inshoot, path_2_ab);
    sweep(profile_2_b_inshoot, path_2_ab);
    //sweep(profile_2, path_2_ab);
  }
}
scale([1,1,4])
tower();
