
"""
A Spark Engine is responsible for controlling how the spark moves.
This basic engine is the default movemet behavior for sparks

Spark objects are Rigid2DBody objects and should be controlled as such

Basic Spark Engine Behavior:
    - In Orbit:
        -The spark will experience a force that pushes it away from or pulls it towards the spark source.
        Force = 3 x dist^2
        'dist' is the distance the spark is from half the orbits radius.  If the spark is closer to the spark source, it
        will be repelled with this force and if it is further, it will be attracted with this force
        the value of 'dist' is also capped, with a maximum of 75% of the orbit's radius.  This prevents forces from building up and getting too extreme
        -While in orbit, the sparks linear velocity will be reduced to it's current speed value  if it should exceed it at any point
            NOTE:  There can still be a moment where velocity is crazy high since this IS NOT done during physics calculations.  However, this moment will pass
            and the speed will be reduced in the following frame.  This makes the movement look more natural in some cases.
    - Launched:
        The spark will fly in a straight direction at a constant rate.  This direction is determined at launch when the player uses
        their active ability and it's speed is it's max current speed.
"""


class_name BasicSparkEngine


# this is a function to initialze the spark engine and should be called when the Spark initializes it for the first time
func init_engine(spark):
    # set initial spark movement values
    spark.linear_damp = 3
    spark.constant_force = Vector2.ZERO


# function to fire the spark.  This should be called once when the spark is launched
func fire_spark(spark, direction : Vector2):
    # clear any forces acting on the spark from normal orbit behavior
    spark.constant_force = Vector2.ZERO
    # set the sparks linear velocity along the direction at it's maximum speed
    spark.linear_velocity = direction * spark.cur_speed
    # remove the dampening effect so that the spark doesn't slow down
    spark.linear_damp = 0


# Function to call to tell the spark how it should move.  Takes the spark object and an idle mode flag as arguments
func drive_spark(spark, is_idle : bool):

    # ======== IN ORBIT ===========  
    # the spark will experience different forces depending on how far it is from the spark source while it is in orbit
    if not spark.has_been_fired:
        # determine which orbit the spark is in
        var orbit_size = 0.0
        if is_idle:
            # select the idle orbit
            orbit_size = spark.spark_source.cur_idle_orbit
        else:
            # select the defensive orbit
            orbit_size = spark.spark_source.cur_defense_orbit
        
        # find the direction and distance from the spark to the spark source
        var source_dir = spark.position.direction_to(spark.spark_source.position)
        var source_dist = spark.position.distance_to(spark.spark_source.position)
        # determine the direction that force will be applied to the spark
        if source_dist < (orbit_size / 2):
            source_dir = source_dir * (-1)
        # find the magnitude of the component of the distance which affects the magnitude of the force
        var dist_mag = abs(source_dist - (orbit_size / 2))
        # limit the size of this component to put an upper end on how much force the spark can experience
        if dist_mag > (orbit_size / 1.25):
            dist_mag = orbit_size / 1.25
        # calculate the magnitude of force to apply to the spark
        var force_mag = pow(dist_mag, 2) * 3    # Force = 3 x dist^2

        # clear any existing constant forces on the spark
        spark.constant_force = Vector2.ZERO
        # set the new constant force
        spark.add_constant_central_force(force_mag * source_dir)

        # limit the linear velocity based on the sparks max speed
        var max_speed = spark.linear_velocity.normalized() * spark.cur_speed
        if max_speed < spark.linear_velocity:
            spark.linear_velocity = max_speed
    
    # ======== LAUNCHED ==========
    # The spark was launched and should not be affected by normal orbit behavior
    else:
        # ensure that there are no extra forces acting on the spark
        spark.constant_force = Vector2.ZERO
        # ensure that the spark is still moving at the right speed in the right direction
        fire_spark(spark, spark.fixed_velocity_vector)