/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = 0
	var/hp = 1800
	var/obj/structure/target_stake/pinnedLoc

/obj/item/target/Destroy()
	removeOverlays()
	if(pinnedLoc)
		pinnedLoc.nullPinnedTarget()
	return ..()

/obj/item/target/proc/nullPinnedLoc()
	pinnedLoc = null
	density = 0

/obj/item/target/proc/removeOverlays()
	overlays.Cut()

/obj/item/target/Move()
	..()
	if(pinnedLoc)
		pinnedLoc.loc = loc

/obj/item/target/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			removeOverlays()
			user << "<span class='notice'>You slice off [src]'s uneven chunks of aluminium and scorch marks.</span>"
	else
		return ..()

/obj/item/target/attack_hand(mob/user)
	if(pinnedLoc)
		pinnedLoc.removeTarget(user)
	..()

/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a syndicate scum."
	hp = 2600

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target that looks like a xenomorphic alien."
	hp = 2350

/obj/item/target/clown
	icon_state = "target_c"
	desc = "A shooting target that looks like a useless clown."
	hp = 2000

#define DECALTYPE_SCORCH 1
#define DECALTYPE_BULLET 2

/obj/item/target/clown/bullet_act(obj/item/projectile/P)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)

/obj/item/target/bullet_act(obj/item/projectile/P)
	var/p_x = P.p_x + pick(0,0,0,0,0,-1,1) // really ugly way of coding "sometimes offset P.p_x!"
	var/p_y = P.p_y + pick(0,0,0,0,0,-1,1)
	var/decaltype = DECALTYPE_SCORCH
	if(istype(/obj/item/projectile/bullet, P))
		decaltype = DECALTYPE_BULLET
	var/icon/C = icon(icon,icon_state)
	if(C.GetPixel(p_x, p_y) && P.original == src && overlays.len <= 35) // if the located pixel isn't blank (null)
		hp -= P.damage
		if(hp <= 0)
			visible_message("<span class='danger'>[src] breaks into tiny pieces and collapses!</span>")
			qdel(src)
		var/image/I = image("icon"='icons/effects/effects.dmi', "icon_state"="scorch", "layer"=OBJ_LAYER+0.5)
		I.pixel_x = p_x - 1 //offset correction
		I.pixel_y = p_y - 1
		if(decaltype == DECALTYPE_SCORCH)
			I.dir = pick(NORTH,SOUTH,EAST,WEST)// random scorch design
			if(P.damage >= 20 || istype(P, /obj/item/projectile/beam/practice))
				I.dir = pick(NORTH,SOUTH,EAST,WEST)
			else
				I.icon_state = "light_scorch"
		else
			I.icon_state = "dent"
		overlays += I
		return
	return -1

#undef DECALTYPE_SCORCH
#undef DECALTYPE_BULLET