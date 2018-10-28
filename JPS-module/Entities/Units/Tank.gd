tool
extends Boid
class_name Tank

onready var WeaponSystem = $Weapon


func attack_command(target):
    BT_context.set("enemy_attack_target", target)
    var path = _get_path(target.position)
    BT_context.set("seek_path", path)
    
    AI_tree = "attack"


func attack(target):
    try_to_shoot(target)


func try_to_shoot(target):
        WeaponSystem.shoot(target)


func die():
    call_deferred('free')