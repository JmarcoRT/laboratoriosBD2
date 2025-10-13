--------------------------------------------------------------------------------
-- Tarea de Paquetes 
-- Alumno: Rosales Trinidad Jeanmarco
--------------------------------------------------------------------------------
-- Ejecutar este script conectado como usuario HR, ya que usa las tablas del esquema HR.

BEGIN DBMS_OUTPUT.ENABLE(NULL); END;
/

--------------------------------------------------------------------------------
-- 1) Tablas de horario, asistencia y ejemplo
--------------------------------------------------------------------------------
-- dia_semana valores: MON,TUE,WED,THU,FRI,SAT,SUN

CREATE TABLE l09_horario (
  dia_semana  VARCHAR2(3) NOT NULL,
  turno       VARCHAR2(10) NOT NULL,
  hora_ini    DATE NOT NULL,
  hora_fin    DATE NOT NULL,
  CONSTRAINT l09_pk_horario PRIMARY KEY (dia_semana, turno)
);

CREATE TABLE l09_empleado_horario (
  employee_id NUMBER(6) NOT NULL,
  dia_semana  VARCHAR2(3) NOT NULL,
  turno       VARCHAR2(10) NOT NULL,
  CONSTRAINT l09_pk_emp_horario PRIMARY KEY (employee_id, dia_semana, turno),
  CONSTRAINT l09_fk_emp_horario_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT l09_fk_emp_horario_hor FOREIGN KEY (dia_semana, turno) REFERENCES l09_horario(dia_semana, turno)
);

CREATE TABLE l09_asistencia_empleado (
  employee_id    NUMBER(6) NOT NULL,
  dia_semana     VARCHAR2(3) NOT NULL,
  turno          VARCHAR2(10) NOT NULL,
  fecha_real     DATE NOT NULL,
  hora_ini_real  DATE NOT NULL,
  hora_fin_real  DATE NOT NULL,
  flag_falta     CHAR(1) DEFAULT 'N',
  CONSTRAINT l09_pk_asistencia PRIMARY KEY (employee_id, fecha_real, turno)
);

BEGIN
  DELETE FROM l09_horario;
EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- horario: lunes a viernes 09:00-18:00, sab 09:00-13:00
INSERT INTO l09_horario VALUES('MON','DIA', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+18/24);
INSERT INTO l09_horario VALUES('TUE','DIA', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+18/24);
INSERT INTO l09_horario VALUES('WED','DIA', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+18/24);
INSERT INTO l09_horario VALUES('THU','DIA', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+18/24);
INSERT INTO l09_horario VALUES('FRI','DIA', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+18/24);
INSERT INTO l09_horario VALUES('SAT','MAN', TRUNC(SYSDATE)+9/24,  TRUNC(SYSDATE)+13/24);
INSERT INTO l09_horario VALUES('SUN','LIB', TRUNC(SYSDATE)+0/24,  TRUNC(SYSDATE)+0/24);
COMMIT;
/

-- empleado_horario: asigna a empleados 100..109 al turno DIA de L-V
BEGIN
  DELETE FROM l09_empleado_horario;
EXCEPTION WHEN OTHERS THEN NULL; END;
/
DECLARE
  v_emp NUMBER := 100;
BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO l09_empleado_horario VALUES(v_emp,'MON','DIA');
    INSERT INTO l09_empleado_horario VALUES(v_emp,'TUE','DIA');
    INSERT INTO l09_empleado_horario VALUES(v_emp,'WED','DIA');
    INSERT INTO l09_empleado_horario VALUES(v_emp,'THU','DIA');
    INSERT INTO l09_empleado_horario VALUES(v_emp,'FRI','DIA');
    v_emp := v_emp + 1;
  END LOOP;
END;
/

-- asistencia_empleado: 10 registros de ejemplo
BEGIN
  DELETE FROM l09_asistencia_empleado;
EXCEPTION WHEN OTHERS THEN NULL; END;
/
DECLARE
  v_base DATE := ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1); -- mes anterior
BEGIN
  FOR d IN 1..10 LOOP
    INSERT INTO l09_asistencia_empleado
    VALUES(100,'MON','DIA', v_base + d, (v_base + d) + 9/24, (v_base + d) + 18/24, 'N');
  END LOOP;
END;
/
COMMIT;
/

--------------------------------------------------------------------------------
-- 2) Tablas de capacitacion + inserts + procedimientos
--------------------------------------------------------------------------------
CREATE TABLE l09_capacitacion (
  capacitacion_id NUMBER(10) PRIMARY KEY,
  nombre          VARCHAR2(100) NOT NULL,
  horas           NUMBER(5,2)   NOT NULL,
  descripcion     VARCHAR2(400)
);

CREATE TABLE l09_empleado_capacitacion (
  employee_id      NUMBER(6) NOT NULL,
  capacitacion_id  NUMBER(10) NOT NULL,
  CONSTRAINT l09_pk_emp_cap PRIMARY KEY (employee_id, capacitacion_id),
  CONSTRAINT l09_fk_emp_cap_emp FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
  CONSTRAINT l09_fk_emp_cap_cap FOREIGN KEY (capacitacion_id) REFERENCES l09_capacitacion(capacitacion_id)
);

BEGIN
  FOR i IN 1..10 LOOP
    INSERT INTO l09_capacitacion VALUES(1000+i, 'curso '||i, 4 + MOD(i,3)*2, 'desc '||i);
  END LOOP;
  INSERT INTO l09_empleado_capacitacion VALUES(100,1001);
  INSERT INTO l09_empleado_capacitacion VALUES(100,1002);
  INSERT INTO l09_empleado_capacitacion VALUES(101,1003);
  INSERT INTO l09_empleado_capacitacion VALUES(102,1004);
  COMMIT;
END;
/

CREATE OR REPLACE FUNCTION l09_horas_capacitaciones_emp(
  p_employee_id IN employees.employee_id%TYPE
) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(c.horas),0)
    INTO v_total
    FROM l09_empleado_capacitacion ec
    JOIN l09_capacitacion c ON c.capacitacion_id = ec.capacitacion_id
   WHERE ec.employee_id = p_employee_id;
  RETURN v_total;
END;
/

CREATE OR REPLACE PROCEDURE l09_lista_capacitaciones IS
BEGIN
  DBMS_OUTPUT.PUT_LINE('capacitacion empleado horas_total');
  FOR r IN (
    SELECT c.nombre AS capacitacion,
           e.last_name||' '||e.first_name AS empleado,
           c.horas AS horas_total
      FROM l09_empleado_capacitacion ec
      JOIN l09_capacitacion c ON c.capacitacion_id = ec.capacitacion_id
      JOIN employees e ON e.employee_id = ec.employee_id
     ORDER BY c.horas DESC, c.nombre, empleado
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(r.capacitacion||' '||r.empleado||' '||r.horas_total);
  END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 3) Triggers 
--------------------------------------------------------------------------------

-- validar insercion de asistencia vs programacion
CREATE OR REPLACE TRIGGER l09_trg_valida_asistencia
BEFORE INSERT ON l09_asistencia_empleado
FOR EACH ROW
DECLARE
  v_dia VARCHAR2(3);
  v_hi DATE; v_hf DATE;
BEGIN
  v_dia := TO_CHAR(:NEW.fecha_real, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');
  v_dia := SUBSTR(v_dia,1,3);
  IF v_dia != :NEW.dia_semana THEN
    RAISE_APPLICATION_ERROR(-20010, 'dia no coincide con fecha');
  END IF;

  SELECT h.hora_ini, h.hora_fin
    INTO v_hi, v_hf
    FROM l09_horario h
   WHERE h.dia_semana = :NEW.dia_semana
     AND h.turno = :NEW.turno;

  IF TO_CHAR(:NEW.hora_ini_real,'HH24:MI') != TO_CHAR(v_hi,'HH24:MI') THEN
    RAISE_APPLICATION_ERROR(-20011, 'hora inicio real no coincide');
  END IF;
  IF TO_CHAR(:NEW.hora_fin_real,'HH24:MI') != TO_CHAR(v_hf,'HH24:MI') THEN
    RAISE_APPLICATION_ERROR(-20012, 'hora fin real no coincide');
  END IF;

  DECLARE v_dummy NUMBER; BEGIN
    SELECT 1 INTO v_dummy
      FROM l09_empleado_horario
     WHERE employee_id = :NEW.employee_id
       AND dia_semana = :NEW.dia_semana
       AND turno = :NEW.turno;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20013, 'empleado no tiene ese turno');
  END;
END;
/

-- validar salario dentro del rango del puesto
CREATE OR REPLACE TRIGGER l09_trg_salario_en_rango
BEFORE INSERT OR UPDATE OF salary, job_id ON employees
FOR EACH ROW
DECLARE
  v_min jobs.min_salary%TYPE;
  v_max jobs.max_salary%TYPE;
  v_job jobs.job_id%TYPE := NVL(:NEW.job_id, :OLD.job_id);
  v_sal employees.salary%TYPE := NVL(:NEW.salary, :OLD.salary);
BEGIN
  SELECT min_salary, max_salary INTO v_min, v_max FROM jobs WHERE job_id = v_job;
  IF v_sal < v_min OR v_sal > v_max THEN
    RAISE_APPLICATION_ERROR(-20020, 'salario fuera de rango para el job');
  END IF;
END;
/

-- restringir registro de ingreso +-30 minutos y marcar inasistencia
CREATE OR REPLACE TRIGGER l09_trg_ventana_ingreso
BEFORE INSERT OR UPDATE OF hora_ini_real ON l09_asistencia_empleado
FOR EACH ROW
DECLARE
  v_hi DATE; v_low DATE; v_high DATE;
BEGIN
  SELECT hora_ini INTO v_hi
    FROM l09_horario
   WHERE dia_semana = :NEW.dia_semana
     AND turno = :NEW.turno;

  v_low  := v_hi - (30/1440);
  v_high := v_hi + (30/1440);

  IF :NEW.hora_ini_real < v_low OR :NEW.hora_ini_real > v_high THEN
    :NEW.flag_falta := 'S';
    :NEW.hora_ini_real := v_hi;
    :NEW.hora_fin_real := v_hi;
  END IF;
END;
/
