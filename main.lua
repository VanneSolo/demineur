function love.load()
  grille_bombes = {}
  grille_compte = {}
  grille_couverture = {}
  
  taille = 35
  font = love.graphics.newFont(15)
  love.graphics.setFont(font)
  game_over = false
  victory = false
  
  nb_lines = 15
  nb_coll = 15
  nb_bombes = 20
  
  for l=1,nb_lines do
    grille_bombes[l] = {}
    grille_compte[l] = {}
    grille_couverture[l] = {}
    for c=1,nb_coll do
      grille_bombes[l][c] = 0
      grille_compte[l][c] = 0
      grille_couverture[l][c] = 1
    end
  end
  
  local nb = 0
  repeat
    local l = love.math.random(2, nb_lines-1)
    local c = love.math.random(2, nb_coll-1)
    if grille_bombes[l][c] == 0 then
      grille_bombes[l][c] = 1
      nb = nb+1
    end
  until nb == nb_bombes
  
  for l=1,nb_lines do
    for c=1,nb_coll do
      local nb_contact = 0
      if grille_bombes[l][c] == 0 then
        nb_contact = nb_contact + Get_Bombe(l-1, c-1)
        nb_contact = nb_contact + Get_Bombe(l-1, c)
        nb_contact = nb_contact + Get_Bombe(l-1, c+1)
        
        nb_contact = nb_contact + Get_Bombe(l, c-1)
        nb_contact = nb_contact + Get_Bombe(l, c+1)
        
        nb_contact = nb_contact + Get_Bombe(l+1, c-1)
        nb_contact = nb_contact + Get_Bombe(l+1, c)
        nb_contact = nb_contact + Get_Bombe(l+1, c+1)
        grille_compte[l][c] = nb_contact
      end
    end
  end
  
end

function love.update(dt)
  local nb_couvertes = 0
  for l=1,nb_lines do
    for c=1,nb_coll do
      if grille_couverture[l][c] ~= 0 then
        nb_couvertes = nb_couvertes + 1
      end
    end
  end
  if nb_couvertes == nb_bombes then
    victory = true
  end
end

function love.draw()
  for l=1,nb_lines do
    for c=1,nb_coll do
      if grille_bombes[l][c] == 1 then
        love.graphics.setColor(1, 0, 0)
      else
        love.graphics.setColor(1, 1, 1)
      end
      love.graphics.rectangle("fill", (c-1)*taille, (l-1)*taille, taille-1, taille-1)
      love.graphics.setColor(0, 0, 0)
      if grille_compte[l][c] ~= 0 then
        love.graphics.print(grille_compte[l][c], (c-1)*taille, (l-1)*taille)
      end
      love.graphics.setColor(0.5, 0.5, 1)
      if grille_couverture[l][c] ~= 0 and game_over == false and victory == false then
        love.graphics.rectangle("fill", (c-1)*taille, (l-1)*taille, taille-1, taille-1)
        if grille_couverture[l][c] == 2 then
          love.graphics.setColor(0, 0, 0)
          love.graphics.print("X", (c-1)*taille, (l-1)*taille)
        end
      end
    end
  end
  if game_over then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("GAME OVER", 15, love.graphics:getHeight()-30)
  elseif victory then
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("VICTOIRE", 15, love.graphics:getHeight()-30)
  end
end

function love.keypressed(key)
  
end

function love.mousepressed(x, y, button)
  if game_over == false then
    local line = math.floor(y/taille) + 1
    local coll = math.floor(x/taille) + 1
    if button == 1 then
      if grille_couverture[line][coll] ~= 2 then
        if grille_bombes[line][coll] == 1 then
          game_over = true
        end
        Flood(line, coll)
      end
    else
      if grille_couverture[line][coll] == 2 then
        grille_couverture[line][coll] = 1
      else
        grille_couverture[line][coll] = 2
      end
    end
  end
end

function Get_Bombe(pLine, pColl)
  if pLine<1 or pLine>nb_lines then return 0 end
  if pColl<1 or pColl>nb_coll then return 0 end
  return grille_bombes[pLine][pColl]
end

function Flood(pLine, pColl)
  if pLine<1 or pLine>nb_lines then return end
  if pColl<1 or pColl>nb_coll then return end
  if grille_compte[pLine][pColl] ~= 0 then
    grille_couverture[pLine][pColl] = 0
    return 
  end
  if grille_couverture[pLine][pColl] == 0 then return end
  grille_couverture[pLine][pColl] = 0
  Flood(pLine-1, pColl)
  Flood(pLine, pColl-1)
  Flood(pLine, pColl+1)
  Flood(pLine+1, pColl)
end