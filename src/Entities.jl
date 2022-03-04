export Renderable
export draw, image_surface, ColorRect, Sprite

draw(e::Entity) = nothing

abstract type Renderable <: Entity end

mutable struct ColorRect <: Renderable
  function ColorRect(p, w, h; color=colorant"white", kw...)
    instantiate!(new(); p=p, w=w, h=h, color=color, kw...)
  end
end

function draw(r::ColorRect)
  TS_VkCmdDrawRect(vulkan_colors(r.color)..., r.p[1]+r.abs_pos.x, r.p[2]+r.abs_pos.y, r.w, r.h, r.abs_rot.z)
end

mutable struct Sprite <: Renderable
  # allow textures larger than a single sprite
  # by supporting cell_size, cell_ind, and region
  # fields. cell_size turns img into a matrix of
  # adjacent regions of the same size starting in
  # the top left of the texture. cell_ind is a 0-indexed
  # (row,col) index into a particular cell. region
  # overrides both and denotes the top-left corner
  # of a rectangle, its width, and its height, and
  # uses only that region of the texture.
  function Sprite(img; cell_size=[0, 0], region=[0, 0, 0, 0], cell_ind=[0, 0], 
    alpha=255, scale=XYZ(1,1,1), kw...)
    instantiate!(new(); img=img, cell_size=cell_size, 
      region=region, cell_ind=cell_ind, 
      alpha=alpha, scale=scale, kw...)
  end
end

function draw(s::Sprite)
  TS_VkCmdDrawSprite(s.img, s.alpha / 255, 
  s.region[1], s.region[2], s.region[3], s.region[4], 
  s.cell_size[1], s.cell_size[2], s.cell_ind[1], s.cell_ind[2],
  s.abs_pos.x, s.abs_pos.y, s.scale.x, s.scale.y, s.abs_rot.z)
end
