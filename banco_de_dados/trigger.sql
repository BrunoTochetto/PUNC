CREATE TRIGGER usuarios_set_grid_before_ins_upd
BEFORE INSERT OR UPDATE OF geom
ON usuarios
FOR EACH ROW
EXECUTE FUNCTION trg_usuarios_set_grid();