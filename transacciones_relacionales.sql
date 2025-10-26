-- Laboratorio: Transacciones Relacionales
-- Alumno: Rosales Trinidad, Jeanmarco

--------------------------------------------------------
-- Ejercicio 1 - Control basico de transacciones
--------------------------------------------------------
BEGIN
  -- Aumentar 10% a salarios del departamento 90
  UPDATE employees
  SET salary = salary * 1.10
  WHERE department_id = 90;

  SAVEPOINT punto1;

  -- Aumentar 5% a salarios del departamento 60
  UPDATE employees
  SET salary = salary * 1.05
  WHERE department_id = 60;

  -- Revertir hasta punto1
  ROLLBACK TO punto1;

  COMMIT;
END;
/

-- Preguntas y respuestas:
-- a) Que departamento mantuvo los cambios?
--    Dept 90 mantuvo el aumento del 10% tras el commit.
-- b) Que efecto tuvo el rollback parcial?
--    Deshizo solo las operaciones posteriores al savepoint punto1.
--    El aumento del 5% en dept 60 no quedo persistente.
-- c) Que ocurriria si se ejecuta ROLLBACK sin savepoint?
--    Revierte toda la transaccion hasta el ultimo commit.

--------------------------------------------------------
-- Ejercicio 2 - Bloqueos entre sesiones 
--------------------------------------------------------
-- Sesion 1:
--   UPDATE employees SET salary = salary + 500 WHERE employee_id = 103;
--   -- No hacer commit
-- Sesion 2:
--   UPDATE employees SET salary = salary + 1000 WHERE employee_id = 103;
--   -- Queda en espera por bloqueo de fila
-- Sesion 1:
--   ROLLBACK; 

-- Vistas utiles:
--   SELECT * FROM v$locked_object;
--   SELECT * FROM v$session;
--   SELECT * FROM v$lock;

-- Preguntas y respuestas:
-- a) Por que la segunda sesion quedo bloqueada?
--    Por bloqueo de fila mantenido por la primera sesion con cambios no confirmados.
-- b) Que comando libera los bloqueos?
--    COMMIT o ROLLBACK en la sesion que mantiene el bloqueo.
-- c) Que vistas permiten verificar sesiones bloqueadas?
--    v$locked_object, v$session, v$lock y dba_waiters.

--------------------------------------------------------
-- Ejercicio 3 - Transaccion controlada con bloque PL/SQL
--------------------------------------------------------
DECLARE
  v_old_dept   NUMBER;
  v_new_dept   NUMBER := 110;
  v_emp_id     NUMBER := 104;
  v_job_id     VARCHAR2(10);
  v_start_date DATE;
BEGIN
  -- Obtener datos actuales del empleado
  SELECT department_id, job_id, hire_date
  INTO v_old_dept, v_job_id, v_start_date
  FROM employees
  WHERE employee_id = v_emp_id;

  -- Transferir empleado al nuevo departamento
  UPDATE employees
  SET department_id = v_new_dept
  WHERE employee_id = v_emp_id;

  -- Registrar en job_history
  INSERT INTO job_history (employee_id, start_date, end_date, job_id, department_id)
  VALUES (v_emp_id, v_start_date, SYSDATE, v_job_id, v_old_dept);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Error en la transferencia: ' || SQLERRM);
END;
/

-- Preguntas y respuestas:
-- a) Por que se debe garantizar la atomicidad?
--    Para evitar estado inconsistente donde se cambie el dept sin registrar en job_history.
--    Ambas operaciones deben ocurrir juntas o ninguna.
-- b) Que pasa si ocurre un error antes del commit?
--    Se ejecuta el rollback del bloque y no persiste ningun cambio.
-- c) Como se asegura la integridad entre employees y job_history?
--    Con claves foraneas y datos consistentes en employee_id, job_id y department_id,
--    mas la confirmacion unica del commit.

--------------------------------------------------------
-- Ejercicio 4 - SAVEPOINT y reversion parcial
--------------------------------------------------------
BEGIN
  -- Aumentar salario 8% para dept 100
  UPDATE employees
  SET salary = salary * 1.08
  WHERE department_id = 100;
  SAVEPOINT A;

  -- Aumentar salario 5% para dept 80
  UPDATE employees
  SET salary = salary * 1.05
  WHERE department_id = 80;
  SAVEPOINT B;

  -- Eliminar empleados del dept 50
  DELETE FROM employees
  WHERE department_id = 50;

  -- Revertir hasta SAVEPOINT B
  ROLLBACK TO B;

  COMMIT;
END;
/

-- Preguntas y respuestas:
-- a) Que cambios quedan persistentes?
--    Los aumentos del 8% en dept 100 y del 5% en dept 80.
-- b) Que sucede con las filas eliminadas?
--    La eliminacion se deshace con el rollback a B y las filas se restauran.
-- c) Como verificar antes y despues del commit?
--    En la misma sesion:
--      SELECT department_id, COUNT(*), SUM(salary) FROM employees
--      GROUP BY department_id;
--    En otra sesion, los cambios solo se veran tras el commit.
