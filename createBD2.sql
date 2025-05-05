create table lugar(
    lugar_id serial,
    lugar_tipo varchar(50) not null,
    lugar_nombre varchar(50) not null,
    FK_Lugar integer,

    constraint PK_lugar primary key (lugar_id),
    --Clave primaria de la tabla Lugar
    constraint FK_lugar_lugar foreign key (FK_Lugar) references Lugar(lugar_id),
    --Clave foranea de la tabla Lugar con Lugar
    constraint check_lugar_tipo check (lugar_tipo IN ('parroquia', 'municipio', 'estado'))
    --Validacion de tipo_lugar
);

create table cliente(
    cliente_id serial,
    cliente_ci varchar(50) not null,
    cliente_p_nombre varchar(50) not null,
    cliente_p_apellido varchar(50) not null,
    cliente_s_nombre varchar(50) not null,
    cliente_s_apellido varchar(50) not null,
    cliente_direccion varchar(50) not null,
    FK_Lugar integer,

    constraint PK_cliente primary key (cliente_id),
    --Clave primaria de la tabla Cliente
    constraint FK_cliente_lugar foreign key (FK_Lugar) references Lugar(lugar_id)
    --Clave foranea de la tabla Cliente con Lugar
);

create table empleado(
    empleado_id serial,
    empleado_ci varchar(50) not null,
    empleado_primer_nombre varchar(50) not null,
    empleado_segundo_nombre varchar(50) not null,
    empleado_primer_apellido varchar(50) not null,
    empleado_segundo_apellido varchar(50) not null,
    empleado_cargo varchar(50) not null,
    empleado_sueldo numeric not null,
    constraint PK_empleado primary key (empleado_id)
    --Clave primaria de la tabla Empleado
);

create table producto(
    producto_id serial,
    producto_nombre varchar(50) not null,
    producto_descripcion varchar(50) not null,

    constraint PK_producto primary key (producto_id)
    --Clave primaria de la tabla Producto
);

create table venta(
    venta_id serial,
    venta_fecha date not null,
    venta_total numeric not null,
    FK_Cliente integer not null,
	FK_Empleado integer not null,

    constraint PK_venta primary key (venta_id),
    -- Clave primaria de la tabla Venta
    constraint FK_venta_cliente foreign key (FK_Cliente) references Cliente(cliente_id),
    -- Clave foranea de la tabla Venta con Cliente
	constraint FK_venta_empleado foreign key (FK_Empleado) references Empleado(empleado_id)
    -- Clave foranea de la tabla Venta con Empleado
);

create table detalle_venta(
    detalle_venta_id serial,    
    detalle_venta_cantidad integer not null,
    detalle_venta_precio_unit numeric not null,
    FK_Venta integer not null,
	FK_Producto integer not null,

    constraint PK_detalle_venta primary key (detalle_venta_id),
    -- Clave primaria de la tabla Detalle_Venta
    constraint FK_detalle_venta_venta foreign key (FK_Venta) references Venta(venta_id),
    -- Clave foranea de la tabla Detalle_Venta con Venta
	constraint FK_venta_producto foreign key (FK_Producto) references Producto(producto_id)
    -- Clave foranea de la tabla Venta con Producto
);

create table proveedor(
    proveedor_id serial,
    proveedor_razon_social varchar(50) not null,
    proveedor_den_comercial varchar(50) not null,
    proveedor_rif varchar(50) not null,
    FK_Lugar integer,

    constraint PK_proveedor primary key (proveedor_id),
    --Clave primaria de la tabla Proveedor
    constraint FK_proveedor_lugar foreign key (FK_Lugar) references Lugar(lugar_id)
    --Clave foranea de la tabla Proveedor con Lugar
);

create table compra (
    compra_id serial,
    compra_fecha date not null,
    compra_total numeric not null,
	FK_Proveedor integer,

    constraint PK_compra primary key (compra_id),
    --Clave primaria de la tabla Compra
	constraint FK_compra_proveedor foreign key (FK_Proveedor) references Proveedor(proveedor_id)
    --Clave foranea de la tabla Compra_Producto con Proveedor
);

create table detalle_compra(
    detalle_compra_id serial,
    detalle_compra_cantidad integer not null,
    detalle_compra_precio_unit numeric not null,
    FK_Compra integer not null,
	FK_Producto integer not null,

    constraint PK_detalle_compra primary key (detalle_compra_id),
    --Clave primaria de la tabla Detalle_Compra
    constraint FK_detalle_compra_compra foreign key (FK_Compra) references Compra(compra_id),
    --Clave foranea de la tabla Detalle_Compra con Compra
	constraint FK_compra_producto foreign key (FK_Producto) references Producto(producto_id)
    --Clave foranea de la tabla Detalle_Compra con Producto
);

create table horario(
    horario_id serial,
    horario_dia varchar(50) not null,
    horario_entrada time not null,
    horario_salida time not null,

    constraint PK_horario primary key (horario_id)
    --Clave primaria de la tabla Horario
);

create table empleado_hora(
    FK_Empleado integer,
    FK_Horario integer,

    constraint PK_empleado_hora primary key (FK_Empleado, FK_Horario),
    --Clave primaria de la tabla Empleado_Hora
    constraint FK_empleado_hora_empleado foreign key (FK_Empleado) references Empleado(empleado_id),
    --Clave foranea de la tabla Empleado_Hora con Empleado
    constraint FK_empleado_hora_horario foreign key (FK_Horario) references Horario(horario_id)
    --Clave foranea de la tabla Empleado_Hora con Horario
);

create table inventario (
    inventario_id serial,
    inventario_descripcion varchar(50) not null,   
    inventario_cantidad integer not null,

    constraint PK_inventario primary key (inventario_id)
    --Clave primaria de la tabla Inventario
);

create table producto_inventario(
    FK_Producto integer,
    FK_Inventario integer,
    fecha_vencimiento date not null,    
    cantidad_presentacion integer not null,

    constraint PK_producto_inventario primary key (FK_Producto, FK_Inventario),
    --Clave primaria de la tabla Producto_Inventario
    constraint FK_producto_inventario_producto foreign key (FK_Producto) references Producto(producto_id),
    --Clave foranea de la tabla Producto_Inventario con Producto
    constraint FK_producto_inventario_inventario foreign key (FK_Inventario) references Inventario(inventario_id)
    --Clave foranea de la tabla Producto_Inventario con Inventario
);

CREATE OR REPLACE FUNCTION reporte8_productos_vencimiento()
    RETURNS TABLE(producto_id integer, producto_nombre character varying, fecha_vencimiento date, dias_restantes integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000
AS $BODY$

BEGIN
    RETURN QUERY 
    SELECT 
        pi.fk_producto AS producto_id, 
        p.producto_nombre, 
        pi.fecha_vencimiento,
        (pi.fecha_vencimiento - CURRENT_DATE) AS dias_restantes
    FROM producto_inventario AS pi
    JOIN producto AS p ON pi.fk_producto = p.producto_id
    order by dias_restantes asc
    limit 5;
END;
$BODY$;

ALTER FUNCTION reporte8_productos_vencimiento()
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION reporte7_top_5_proveedores(
)
    RETURNS TABLE(proveedor_razon_social varchar(50), total bigint, fk_proveedor integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 

BEGIN
    RETURN QUERY
	
    select pro.proveedor_razon_social, COUNT(co.compra_id) as total, co.fk_proveedor
from proveedor as pro, compra as co
where pro.proveedor_id = co.fk_proveedor
group by co.fk_proveedor, pro.proveedor_razon_social
order by total desc
limit 5;

END;
$BODY$;

CREATE OR REPLACE FUNCTION reporte6_lugar_con_mas_clientes()
    RETURNS TABLE(lugar_nombre character varying, num_clientes bigint) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    select l.lugar_nombre, count(c.fk_lugar) as num_clientes
from lugar as l, cliente as c
where c.fk_lugar is not null and c.fk_lugar = l.lugar_id and l.lugar_tipo = 'parroquia'
group by c.fk_lugar, l.lugar_nombre
order by num_clientes DESC
limit 5;

END;
$BODY$;

ALTER FUNCTION reporte6_lugar_con_mas_clientes()
    OWNER TO postgres;


CREATE OR REPLACE FUNCTION reporte5_producto_mas_comprado_cliente(
	)
    RETURNS TABLE(cliente_p_nombre character varying, cliente_p_apellido character varying, producto_nombre character varying) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
    top_clientes RECORD;
BEGIN
    -- Seleccionar los 5 clientes con más ventas
    FOR top_clientes IN
        SELECT c.cliente_p_nombre, c.cliente_p_apellido
        FROM cliente c,venta v
		WHERE c.cliente_id = v.FK_Cliente
        GROUP BY c.cliente_p_nombre, c.cliente_p_apellido
        ORDER BY COUNT(*) DESC
        LIMIT 5
    LOOP
        -- Encontrar el producto más comprado por cada cliente
        RETURN QUERY
        SELECT top_clientes.cliente_p_nombre,
               top_clientes.cliente_p_apellido,
               p.producto_nombre
        FROM cliente c,venta v, detalle_venta dv, producto p
		WHERE c.cliente_id = v.FK_Cliente AND v.venta_id = dv.FK_Venta
        AND dv.FK_Producto = p.producto_id
        AND c.cliente_p_nombre = top_clientes.cliente_p_nombre
        AND c.cliente_p_apellido = top_clientes.cliente_p_apellido
        GROUP BY c.cliente_p_nombre, c.cliente_p_apellido, p.producto_nombre
        ORDER BY COUNT(*) DESC
        LIMIT 1;
    END LOOP;
END;
$BODY$;

CREATE OR REPLACE FUNCTION reporte4_obtener_empleado_con_mas_ventas(fecha_inicio DATE, fecha_fin DATE)
RETURNS TABLE (nombre varchar(50), total_ventas NUMERIC) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        e.empleado_primer_nombre as nombre,
        SUM(v.venta_total) AS total_ventas
    FROM
        venta v, empleado e
    WHERE
        e.empleado_id = v.FK_Empleado AND v.venta_fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY
        nombre
    ORDER BY
        total_ventas DESC
    LIMIT 4;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reporte3_obtener_mes_con_mas_ventas(fecha_inicio DATE, fecha_fin DATE)
RETURNS TABLE (mes TEXT, total_ventas NUMERIC) AS
$$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(venta_fecha, 'Month') AS mes,
        SUM(venta_total) AS total_ventas
    FROM
        venta
    WHERE
        venta_fecha BETWEEN fecha_inicio AND fecha_fin
    GROUP BY
        mes
    ORDER BY
        total_ventas DESC
    LIMIT 4;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reporte2_precios_productos()
RETURNS TABLE (producto_nombre VARCHAR(50), precio_unitario NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT p.producto_nombre, dc.detalle_compra_precio_unit AS precio_unitario
    FROM producto p, detalle_compra dc
	WHERE p.producto_id = dc.FK_Producto
    ORDER BY precio_unitario DESC;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reporte1_productos_vendidos(fecha_desde date,fecha_hasta date)
RETURNS TABLE (producto_nombre VARCHAR(50), total_vendido BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT p.producto_nombre, SUM(dv.detalle_venta_cantidad) AS total_vendido
    FROM producto p, detalle_venta dv, venta v
	WHERE p.producto_id = dv.FK_Producto AND dv.FK_Venta = v.venta_id
	AND v.venta_fecha BETWEEN fecha_desde AND fecha_hasta
    GROUP BY p.producto_nombre
    ORDER BY total_vendido DESC;
END;
$$ LANGUAGE plpgsql;
