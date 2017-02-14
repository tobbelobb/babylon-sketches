use <sweep.scad>

module tower(){
  profile_l = 15;
  profile_h = 17;
  profile_slope_factor = 1.1;
  bottom_radius = 300;
  rounds_0 = 75;
  //rounds_0 = 2;
  rounds_ab = 60;
  //rounds_ab = 6;
  extra_rounds = 3;
  gap = 0.01;
  s = 13;
  outshoot = 45;
  spike_ang = s/5;
  inshoot = 8 + spike_ang;
  echo(inshoot);
  scalefac = 1.4;
  small_d = 2.2*profile_l;
  echo(small_d);
  spikelim = 0.6;

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

  profile_1 = [for (v=[0:s:360-s])
                [(bottom_radius-scalefac*profile_l)*cos(v),
                 (bottom_radius-scalefac*profile_l)*sin(v),
                 0]];
  profile_2_a = [for (v=[-10:s/4:10])
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
  profile_2_b = [for (v=[170:s/4:190])
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

  function retract_spikes(v) = abs(v) > spikelim ?
                               5*sqrt(3*abs(v)) :
                               5*sqrt(3*abs(spikelim)) + 15*(cos(v) - cos(spikelim));

  path_0 = [for (v_0=[360+spike_ang:s:rounds_0*360])
    for(extr = [-spike_ang:s/20:spike_ang])
    rotation([0,0,v_0+extr]) *
    translation([move_inwards(v_0+extr) < bottom_radius - small_d ?
                 r(v_0) - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(extr):
                 max(r(v_0) - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(extr), small_d - ((move_inwards(v_0)-move_inwards(v_0-360))/profile_l)*retract_spikes(spike_ang)),
                 0,
                 h(v_0+extr)]) *
    scaling([(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,
                 1,
             1+(move_upwards(v_0+extr) - move_upwards(v_0+extr-360))/(profile_slope_factor*profile_h)]) *
    translation([profile_l,0,0])
    ];


  function spiral(rounds, spiraling_factor = 1) =
    [for (v_1=[0:40:rounds*360])
    rotation([0,0,spiraling_factor*(h(v_1)/(r(v_1)+outshoot))*4*170/(PI)]) *
      translation([0,0,
          h(v_1)]) *
      scaling([move_inwards(v_1) < bottom_radius - small_d ?
          (r(v_1))/(bottom_radius-(1.0*profile_l)) :
          (small_d)/(bottom_radius-(1.0*profile_l)),
          move_inwards(v_1) < bottom_radius - small_d ?
          (r(v_1))/(bottom_radius-(1.0*profile_l)) :
          (small_d)/(bottom_radius-(1.0*profile_l)),
          1])];

  infillrounds = 1.2;

  //path_1 = spiral(rounds_0 + extra_rounds);
  path_1 = spiral(infillrounds);
  //path_2 = spiral(infillrounds);
  path_2_ab = spiral(rounds_ab);
  path_2_ab_mirrored = spiral(rounds_ab, -1);
  //path_2_ab = spiral(rounds_0);

  //for(v=[0:s:360]){
  //  echo(v)
  //  transform(v, to_3d(profile_2_a));
  //}

  
  module door(){
  y = 15;
  x = 5;
  z = profile_h*profile_slope_factor-y/2;
  translate([-x/2,-y/2,-profile_h*profile_slope_factor+gap+0.5])
    cube([x,y,z]);
  translate([0,0,-y/2+1])
    scale([1,1,0.5])
    rotate([0,90,0])
    cylinder(d=y, h=x, center=true);
  }

  module doors(){
    for (v_0=[360*2:2*s:360*2 + 15*360]){
      rotate([0,0,v_0])
      translate([
           r(v_0),
           0,
           h(v_0)])  
      rotate([0,0,2])
        scale([1,0.5+0.5*(move_inwards(v_0)-move_inwards(v_0-360))/profile_l,1+(move_upwards(v_0) - move_upwards(v_0-360))/(profile_slope_factor*profile_h)])
      door();
    }
  }

  module doorless_tower(){
    difference(){
      sweep(profile_0, path_0);

      #doors();
    }
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
  doorless_tower();
  //import("sketch_24_placement_helper.stl");
  
  
  //difference(){
//    %import("sketch_23.stl");
//    scale([1,1,4])
//      doorless_tower();
//    scale([1,1,4])
//      #doors();
  //}

}
tower();

//difference(){
//  import("sketch_23_rep.stl");
//  tower();
//}

