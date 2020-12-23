use master
go
if(DB_ID('bd_ventas_express')is not null)
drop DataBase bd_ventas_express
create DataBase bd_ventas_express
go

use bd_ventas_express
go
ALTER AUTHORIZATION ON DATABASE ::bd_ventas_express TO SA
GO

-- ********************************************************
-- HABILITAR CONEXIONES REMOTAS
IF(USER_ID('user_ventas_express')IS NULL)
BEGIN
	-- Creates the login with password 
	CREATE LOGIN user_ventas_express WITH PASSWORD = 'xyz12345678';  
	  
	-- Creates a database user for the login created above.  
	CREATE USER user_ventas_express FOR LOGIN user_ventas_express;

	-- Permitir conexiones remotas
	EXEC sp_configure 'remote access', 1 ;  
	RECONFIGURE ; 

	-- configurar la opción de conexiones de usuario
	EXEC sp_configure 'show advanced options', 1;  
	RECONFIGURE ;  
	EXEC sp_configure 'user connections', 325; --cantidad de conexiones  
	RECONFIGURE; 

END
GO
-- ********************************************************


-- ==============================================
--                 TABLA AREA
-- ==============================================

create table Area
(IdArea int identity(1,1) primary key,
Nombre varchar(30) not null,
Estado char(1) check(Estado in('0','1')) not null
)
go

--------------------------------------------
Create Proc Listar_Area
as begin
	select IdArea, Nombre, Estado from Area	
   end
go

--------------------------------------------
Create Proc Listar_Area_Activa
as begin
	select IdArea, Nombre, Estado from Area	where Estado='1'
   end
go

--------------------------------------------
Create Proc Registrar_Area
@Nombre varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(exists(select * from Area where Nombre=@Nombre))
	set @Mensaje='Area ya está Registrado.'
	else begin
	 insert Area values(@Nombre,@Estado)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

--------------------------------------------
Create Proc Actualizar_Area
@IdArea int,
@Nombre varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Area where IdArea=@IdArea))
	set @Mensaje='El área no existe'
	else begin
	 update Area set Nombre=@Nombre, Estado=@Estado where IdArea=@IdArea
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

--------------------------------------------
Create Proc Eliminar_Area
@IdArea int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Area where IdArea=@IdArea))
	set @Mensaje='Código del área no se encuentra disponible, o no Existe.'
	else begin
	 delete from Area where IdArea=@IdArea
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

--------------------------------------------
Create Proc Buscar_Area
@Buscar varchar(30)
as begin
 select * from Area where Nombre like '%'+@Buscar+'%'
 end
go

-- ==============================================
--                 TABLA Usuario
-- ==============================================

create table Usuario
(IdUsuario int identity(1,1) primary key,
DocIdentidad varchar(20) not null UNIQUE,
Apellidos varchar(50) not null,
Nombres varchar(50) not null,
Sexo char(1) check(Sexo in('M','F')) not null,
IdArea int not null,
Direccion varchar(100),
Telefono varchar(30),
Correo varchar(50),
Usuario varchar(30) not null UNIQUE,
Clave varchar(20) not null,
Estado char(1) check(Estado in('0','1')) not null
foreign key(IdArea) references Area(IdArea)
)
go

--------------------------------------------
Create Proc Listar_Usuario
as begin
	select U.*, A.Nombre as 'Area' 
	from Usuario U join Area A on U.IdArea=A.IdArea
   end
go

--------------------------------------------
Create Proc Listar_Usuario_Activo  
as begin
	select U.*, A.Nombre as 'Area', concat( U.Nombres, ' ', U.Apellidos) as 'NombresApellidos' 
	from Usuario U join Area A on U.IdArea=A.IdArea where U.Estado='1'
   end
go

--------------------------------------------
Create Proc Listar_Usuario_Activo_xIdArea  
@IdArea int
as begin
	select U.*, A.Nombre as 'Area', concat( U.Nombres, ' ', U.Apellidos) as 'NombresApellidos' 
	from Usuario U join Area A on U.IdArea=A.IdArea where U.IdArea=@IdArea and U.Estado='1'
   end
go

--------------------------------------------
Create Proc Registrar_Usuario
@DocIdentidad varchar(20),
@Apellidos varchar(50),
@Nombres varchar(50),
@Sexo char(1),
@IdArea int,
@Direccion varchar(100),
@Telefono varchar(30),
@Correo varchar(50),
@Usuario varchar(30),
@Clave varchar(20),
@Estado char(1),
@Token varchar(9)
as begin
	if(exists(select * from Usuario where DocIdentidad=@DocIdentidad or Usuario=@Usuario))
		select '0' as 'Return','DocIdentidad o Usuario ya existe' as 'Mensaje'
	else begin
		insert Usuario values(@DocIdentidad,@Apellidos,@Token,@Sexo,@IdArea,@Direccion,@Telefono,@Correo,@Usuario,@Clave,@Estado)
		select '1' as 'Return','Registrado correctamente' as 'Mensaje', IdUsuario from Usuario where Nombres=@Token
		update Usuario set Nombres=@Nombres where Nombres=@Token
	 end
   end
go

--------------------------------------------
Create Proc Actualizar_Usuario
@IdUsuario int,
@DocIdentidad varchar(20),
@Apellidos varchar(50),
@Nombres varchar(50),
@Sexo char(1),
@IdArea int,
@Direccion varchar(100),
@Telefono varchar(30),
@Correo varchar(50),
@Usuario varchar(30),
@Clave varchar(20),
@Estado char(1)
as begin
	if(not exists(select * from Usuario where IdUsuario=@IdUsuario))
		select '0' as 'Return','El ID del Usuario no existe o el Usuario ya existe' as 'Mensaje'
	else begin
		update Usuario set DocIdentidad=@DocIdentidad, Apellidos=@Apellidos, Nombres=@Nombres,Sexo=@Sexo, IdArea=@IdArea,Direccion=@Direccion,Telefono=@Telefono,Correo=@Correo,Usuario=@Usuario,Clave=@Clave,Estado=@Estado where IdUsuario=@IdUsuario
		select '1' as 'Return','Actualizado correctamente' as 'Mensaje'
     end
  end
go

--------------------------------------------
Create Proc Eliminar_Usuario
@IdUsuario int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Usuario where IdUsuario=@IdUsuario))
	set @Mensaje='DocIdentidad del Usuario no se encuentra disponible, o no Existe.'
	else begin
	 delete from Usuario where IdUsuario=@IdUsuario
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

--------------------------------------------
Create Proc Buscar_Usuario
@Buscar varchar(30)
as begin
 select U.*, A.Nombre from Usuario U join Area A on U.IdArea=A.IdArea
 where U.Nombres like '%'+@Buscar+'%' or U.Apellidos like '%'+@Buscar+'%' or U.DocIdentidad like '%'+@Buscar+'%' or A.Nombre like '%'+@Buscar+'%'
 end
go

--------------------------------------------
-- SP CONSULTAR SI EXISTE USUARIO
Create Proc Existe_Usuario
@Usuario varchar(30)
as begin
	if(not exists(select * from Usuario where Usuario=@Usuario))
		select '0' as 'Return','Usuario no existe' as 'Mensaje'
	else begin		
		select '1' as 'Return','Usuario ya existe' as 'Mensaje'
     end
 end
go

------------------------------------------
Create Proc Login_Usuario
@Usuario varchar(30),
@Clave varchar(20)
as begin
	if(not exists(select * from Usuario where Usuario=@Usuario and Clave=@Clave and Estado='1'))		
		select 0 as 'Login'
	else begin
		select 1 as 'Login', IdUsuario, Usuario,CONCAT(Nombres, ' ', Apellidos) from Usuario where Usuario=@Usuario and Clave=@Clave and Estado='1'
	 end
  end
go

------------------------------------------
Create Proc Cambiar_Clave
@Usuario varchar(30),
@Clave varchar(20),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Usuario where Usuario=@Usuario))
	set @Mensaje='El usuario no existe'
	else begin
	 update Usuario set Clave=@Clave where Usuario=@Usuario
	 set @Mensaje='Clave actualizada correctamente.'
     end
  end
go

------------------------------------------
--CREAR UN SP QUE PERMITA BUSCAR DEPENDENCIA ENTRE TABLAS
Create Proc Dependencia_Usuario_IdArea_Area
@IdArea int
as begin
 select count(*) as Total from Usuario where IdArea= @IdArea
 end
go


-- ==============================================
--                 TABLA Permiso
-- ==============================================

create table Permiso
(IdPermiso int identity(1,1) primary key,
IdUsuario int not null,
per1 bit, 
per2 bit,
per3 bit,
per4 bit,
per5 bit,
per6 bit,
per7 bit,
per8 bit,
per9 bit,
per10 bit,
per11 bit,
per12 bit,
per13 bit,
foreign key(IdUsuario) references Usuario(IdUsuario)
)
go

------------------------------------------
Create Proc Registrar_Permiso
@IdUsuario int,
@per1 bit, 
@per2 bit,
@per3 bit,
@per4 bit,
@per5 bit,
@per6 bit,
@per7 bit,
@per8 bit,
@per9 bit,
@per10 bit,
@per11 bit,
@per12 bit,
@per13 bit,
@Mensaje varchar(100) out
as begin
	if(exists(select * from Permiso where IdUsuario=@IdUsuario))
	set @Mensaje='IdUsuario ya está Registrado.'
	else begin
	 insert Permiso values(@IdUsuario, @per1, @per2, @per3, @per4, @per5, @per6, @per7, @per8, @per9, @per10, @per11, @per12, @per13)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

------------------------------------------
Create Proc Actualizar_Permiso
@IdUsuario int,
@per1 bit, 
@per2 bit,
@per3 bit,
@per4 bit,
@per5 bit,
@per6 bit,
@per7 bit,
@per8 bit,
@per9 bit,
@per10 bit,
@per11 bit,
@per12 bit,
@per13 bit,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Permiso where IdUsuario=@IdUsuario))
	set @Mensaje='El Permiso no existe'
	else begin
	 update Permiso set per1=@per1, per2=@per2, per3=@per3, per4=@per4, per5=@per5, per6=@per6, per7=@per7, per8=@per8, per9=@per9, per10=@per10, per11=@per11, per12=@per12, per13=@per13 
	 where IdUsuario=@IdUsuario
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

------------------------------------------
Create Proc Eliminar_Permiso
@IdUsuario int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Permiso where IdUsuario=@IdUsuario))
	set @Mensaje='IdUsuario no se encuentra disponible, o no Existe.'
	else begin
	 delete from Permiso where IdUsuario=@IdUsuario
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

------------------------------------------
Create Proc Buscar_Permiso
@IdUsuario int
as begin
	select * from Permiso where IdUsuario= @IdUsuario
 end
go


-- ==============================================
--                 TABLA Cliente
-- ==============================================

create table Cliente
(IdCliente int identity(1,1) primary key,
DocIdentidad varchar(20),
Apellidos varchar(50),
Nombres varchar(50),
Sexo char(1) check(Sexo in('M','F')) not null,
Direccion varchar(100),
Telefono varchar(30),
Correo varchar(50),
Estado char(1) check(Estado in('0','1')) not null
)
go

--------------------------------------------
Create Proc Listar_Cliente
as begin
	select * from Cliente
   end
go

--------------------------------------------
Create Proc Listar_Cliente_Activo  
as begin
	select C.*, concat( C.Nombres, ' ', C.Apellidos) as 'NombresApellidos' 
	from Cliente C where C.Estado='1'
   end
go

--------------------------------------------
Create Proc Registrar_Cliente
@DocIdentidad varchar(20),
@Apellidos varchar(50),
@Nombres varchar(50),
@Sexo char(1),
@Direccion varchar(100),
@Telefono varchar(30),
@Correo varchar(50),
@Estado char(1),
@Token varchar(9)
as begin
	if(exists(select * from Cliente where DocIdentidad=@DocIdentidad))
		select '0' as 'Return','DocIdentidad' as 'Mensaje'
	else begin
		insert Cliente values(@DocIdentidad,@Apellidos,@Token,@Sexo,@Direccion,@Telefono,@Correo,@Estado)
		select '1' as 'Return','Registrado correctamente' as 'Mensaje', IdCliente from Cliente where Nombres=@Token
		update Cliente set Nombres=@Nombres where Nombres=@Token
	 end
   end
go

--------------------------------------------
Create Proc Actualizar_Cliente
@IdCliente int,
@DocIdentidad varchar(20),
@Apellidos varchar(50),
@Nombres varchar(50),
@Sexo char(1),
@Direccion varchar(100),
@Telefono varchar(30),
@Correo varchar(50),
@Estado char(1)
as begin
	if(not exists(select * from Cliente where IdCliente=@IdCliente))
		select '0' as 'Return','El ID del Cliente no existe o el Cliente ya existe' as 'Mensaje'
	else begin
		update Cliente set DocIdentidad=@DocIdentidad, Apellidos=@Apellidos, Nombres=@Nombres,Sexo=@Sexo,Direccion=@Direccion,Telefono=@Telefono,Correo=@Correo,Estado=@Estado where IdCliente=@IdCliente
		select '1' as 'Return','Actualizado correctamente' as 'Mensaje'
     end
  end
go

--------------------------------------------
Create Proc Eliminar_Cliente
@IdCliente int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Cliente where IdCliente=@IdCliente))
	set @Mensaje='DocIdentidad del Cliente no se encuentra disponible, o no Existe.'
	else begin
	 delete from Cliente where IdCliente=@IdCliente
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

--------------------------------------------
Create Proc Buscar_Cliente
@Buscar varchar(30)
as begin
 select C.*, concat( C.Nombres, ' ', C.Apellidos) as 'NombresApellidos' 
 from Cliente C
 where C.Nombres like '%'+@Buscar+'%' or C.Apellidos like '%'+@Buscar+'%' or C.DocIdentidad like '%'+@Buscar+'%'
 end
go


-- ==============================================
--                 TABLA CATEGORIA
-- ==============================================

create table Categoria
(IdCategoria int identity(1,1) primary key,
Nombre varchar(30) not null,
Estado char(1) check(Estado in('0','1')) not null
)
go

------------------------------------------
Create Proc Listar_Categoria
as begin
	select IdCategoria, Nombre, Estado from Categoria	
   end
go

------------------------------------------
Create Proc Listar_Categoria_Activa
as begin
	select IdCategoria, Nombre, Estado from Categoria where Estado='1'
   end
go

------------------------------------------
Create Proc Registrar_Categoria
@Nombre varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(exists(select * from Categoria where Nombre=@Nombre))
	set @Mensaje='Categoría ya está registrado.'
	else begin
	 insert Categoria values(@Nombre,@Estado)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

------------------------------------------
Create Proc Actualizar_Categoria
@IdCategoria int,
@Nombre varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Categoria where IdCategoria=@IdCategoria))
	set @Mensaje='Categoría no existe'
	else begin
	 update Categoria set Nombre=@Nombre, Estado=@Estado where IdCategoria=@IdCategoria
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

------------------------------------------
Create Proc Eliminar_Categoria
@IdCategoria int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Categoria where IdCategoria=@IdCategoria))
	set @Mensaje='Código de Categoría no se encuentra disponible, o no Existe.'
	else begin
	 delete from Categoria where IdCategoria=@IdCategoria
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

------------------------------------------
Create Proc Buscar_Categoria
@Buscar varchar(30)
as begin
 select * from Categoria where Nombre like '%'+@Buscar+'%'
 end
go


-- ==============================================
--                 TABLA UMEDIDA
-- ==============================================

create table UMedida
(IdUMedida int identity(1,1) primary key,
Nombre varchar(30) not null,
Abreviatura varchar(10) not null,
Estado char(1) check(Estado in('0','1')) not null
)
go

------------------------------------------
Create Proc Listar_UMedida
as begin
	select IdUMedida, Nombre,Abreviatura, Estado from UMedida	
   end
go

------------------------------------------
Create Proc Listar_UMedida_Activa
as begin
	select IdUMedida, Nombre,Abreviatura, Estado from UMedida where Estado='1'
   end
go

------------------------------------------
Create Proc Registrar_UMedida
@Nombre varchar(30),
@Abreviatura varchar(10),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(exists(select * from UMedida where Nombre=@Nombre or Abreviatura=@Abreviatura))
	set @Mensaje='Unidad o abreviatura ya está registrado.'
	else begin
	 insert UMedida values(@Nombre,@Abreviatura,@Estado)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

------------------------------------------
Create Proc Actualizar_UMedida
@IdUMedida int,
@Nombre varchar(30),
@Abreviatura varchar(10),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from UMedida where IdUMedida=@IdUMedida))
	set @Mensaje='Unidad de Medida no existe'
	else begin
	 update UMedida set Nombre=@Nombre, Abreviatura=@Abreviatura, Estado=@Estado where IdUMedida=@IdUMedida
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

------------------------------------------
Create Proc Eliminar_UMedida
@IdUMedida int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from UMedida where IdUMedida=@IdUMedida))
	set @Mensaje='Código de Unidad de Medida no se encuentra disponible, o no Existe.'
	else begin
	 delete from UMedida where IdUMedida=@IdUMedida
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

------------------------------------------
Create Proc Buscar_UMedida
@Buscar varchar(30)
as begin
 select * from UMedida where Nombre like '%'+@Buscar+'%'
 end
go


-- ==============================================
--                 TABLA PRODUCTO
-- ==============================================

create table Producto
(IdProducto int identity(1,1) primary key,
IdCategoria int not null,
IdUMedida int not null,
Descripcion varchar(100) not null,
Codbarra varchar(20),
Stock int,
PrecioCompra numeric(8,2),
PrecioVenta numeric(8,2),
Estado char(1) check(Estado in('0','1')) not null
foreign key(IdCategoria) references Categoria(IdCategoria),
foreign key(IdUMedida) references UMedida(IdUMedida)
)
go

------------------------------------------
Create Proc Listar_Producto
as begin
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	End
go

------------------------------------------
Create Proc Listar_Producto_Activo
as begin
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	where P.Estado='1'
	End
go

------------------------------------------
Create Proc Registrar_Producto
@IdCategoria int,
@IdUMedida int,
@Descripcion varchar(100),
@Codbarra varchar(20),
@Stock int,
@PrecioCompra numeric(12,2),
@PrecioVenta numeric(12,2),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(exists(select * from Producto where Descripcion=@Descripcion))
	set @Mensaje='Producto ya está Registrado.'
	else begin
	 insert Producto values(@IdCategoria,@IdUMedida,@Descripcion,@Codbarra,@Stock,@PrecioCompra,@PrecioVenta,@Estado)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

------------------------------------------
Create Proc Actualizar_Producto
@IdProducto int,
@IdCategoria int,
@IdUMedida int,
@Descripcion varchar(100),
@Codbarra varchar(20),
@Stock int,
@PrecioCompra numeric(12,2),
@PrecioVenta numeric(12,2),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Producto where IdProducto=@IdProducto))
	set @Mensaje='El Producto no existe'
	else begin
	 update Producto set IdCategoria=@IdCategoria, IdUMedida=@IdUMedida, Descripcion=@Descripcion, Codbarra=@Codbarra, Stock=@Stock, PrecioCompra=@PrecioCompra, PrecioVenta=@PrecioVenta, Estado=@Estado where IdProducto=@IdProducto
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

------------------------------------------
Create Proc Eliminar_Producto
@IdProducto int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Producto where IdProducto=@IdProducto))
	set @Mensaje='Código del Producto no se encuentra disponible, o no Existe.'
	else begin
	 delete from Producto where IdProducto=@IdProducto
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

------------------------------------------
Create Proc Buscar_Producto
@Buscar varchar(30)
as begin 
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida', CONCAT(P.Codbarra,' - ',P.Descripcion,' - ',C.Nombre) as 'Producto'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	where P.Descripcion like '%'+@Buscar+'%' or C.Nombre like '%'+@Buscar+'%' or P.Codbarra like '%'+@Buscar+'%'
 end
go

------------------------------------------
Create Proc Buscar_Producto_Activo
@Buscar varchar(30)
as begin
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida', CONCAT(P.Codbarra,' - ',P.Descripcion,' - ',C.Nombre) as 'Producto'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	where (P.Descripcion like '%'+@Buscar+'%' or C.Nombre like '%'+@Buscar+'%' or P.Codbarra like '%'+@Buscar+'%')  and P.Estado='1'
	order by C.Nombre asc, P.Descripcion asc
 end
go

------------------------------------------
Create Proc Buscar_Producto_xIdProducto
@IdProducto int
as begin
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida', CONCAT(P.Codbarra,' - ',P.Descripcion,' - ',C.Nombre) as 'Producto'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	where IdProducto= @IdProducto
 end
go

------------------------------------------
Create Proc Buscar_Producto_xCodbarra
@Codbarra varchar(20)
as begin
	select P.*, C.Nombre as 'Categoría', U.Abreviatura as 'U.Medida', CONCAT(P.Codbarra,' - ',P.Descripcion,' - ',C.Nombre) as 'Producto'
	from Producto P join Categoria C on P.IdCategoria=C.IdCategoria join UMedida U on P.IdUMedida=U.IdUMedida
	where Codbarra= @Codbarra
 end
go

------------------------------------------
Create Proc Actualizar_Producto_Stock
@IdProducto int,
@SumarRestar int
as begin
	 update Producto set Stock=Stock+@SumarRestar where IdProducto=@IdProducto
  end
go


-- ==============================================
--                 TABLA PROVEEDOR
-- ==============================================

create table Proveedor
(IdProveedor int identity(1,1) primary key,
RegContribuyente varchar(20),
Empresa varchar(50) not null,
Direccion varchar(100),
Telefono varchar(30),
Estado char(1) check(Estado in('0','1')) not null
)
go

------------------------------------------
Create Proc Registrar_Proveedor
@RegContribuyente varchar(20),
@Empresa varchar(50),
@Direccion varchar(100),
@Telefono varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(exists(select * from Proveedor where RegContribuyente=@RegContribuyente or Empresa=@Empresa))
	set @Mensaje='Registro del contribuyente o nombre de Empresa ya está registrado.'
	else begin
	 insert Proveedor values(@RegContribuyente,@Empresa,@Direccion,@Telefono,@Estado)
	 set @Mensaje='Registrado Correctamente.'
	 end
   end
go

------------------------------------------
Create Proc Actualizar_Proveedor
@IdProveedor int,
@RegContribuyente varchar(20),
@Empresa varchar(50),
@Direccion varchar(100),
@Telefono varchar(30),
@Estado char(1),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Proveedor where IdProveedor=@IdProveedor))
	set @Mensaje='Proveedor no existe'
	else begin
	 update Proveedor set RegContribuyente=@RegContribuyente,Empresa=@Empresa,Direccion=@Direccion,Telefono=@Telefono, Estado=@Estado where IdProveedor=@IdProveedor
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go

------------------------------------------
Create Proc Eliminar_Proveedor
@IdProveedor int,
@Mensaje varchar(100) out
as begin
	if(not exists(select * from Proveedor where IdProveedor=@IdProveedor))
	set @Mensaje='Código de Proveedor no se encuentra disponible, o no Existe.'
	else begin
	 delete from Proveedor where IdProveedor=@IdProveedor
	 set @Mensaje='Registro Eliminado Satisfactoriamente.'
	 end
  end
go

------------------------------------------
Create Proc Buscar_Proveedor
@Buscar varchar(30)
as begin
 select *, CONCAT(RegContribuyente,' - ',Empresa) as 'RegContrib_Empresa' from Proveedor where (RegContribuyente like '%'+@Buscar+'%' or Empresa like '%'+@Buscar+'%')
 end
go

------------------------------------------
Create Proc Buscar_Proveedor_Activo
@Buscar varchar(30)
as begin
 select *, CONCAT(RegContribuyente,' - ',Empresa) as 'RegContrib_Empresa' from Proveedor where (RegContribuyente like '%'+@Buscar+'%' or Empresa like '%'+@Buscar+'%') and Estado='1'
 end
go


-- ==============================================
--                 TABLA GenericTable
-- ==============================================

create table GenericTable 
(Objeto varchar(50),
Id int,
Codigo varchar(50),
ValorTexto varchar(100),
ValorNumero Decimal(8,3)
)
go

--------------------------------------------
Create Proc Listar_GenericTable_xObjeto
@Objeto varchar(30)
as begin
 select * from GenericTable where Objeto=@Objeto
 end
go

------------------------------------------
Create Proc Actualizar_GenericTable_xObjeto_xId
@Objeto varchar(20),
@Id int,
@Codigo varchar(20),
@ValorTexto varchar(50),
@ValorNumero Decimal(8,5),
@Mensaje varchar(100) out
as begin
	if(not exists(select * from GenericTable where Objeto=@Objeto and Id=@Id))
	set @Mensaje='Id no existe'
	else begin
	 update GenericTable set Codigo=@Codigo, ValorTexto=@ValorTexto, ValorNumero=@ValorNumero where Objeto=@Objeto and Id=@Id
	 set @Mensaje='Datos Actualizados Correctamente.'
     end
  end
go


-- ==============================================
--                 TABLA EXISTENCIA
-- ==============================================

create table Existencia
(IdExistencia int identity(1,1) primary key,
IdCategoria int,
Categoria varchar(30),
Codbarra varchar(20),
IdProducto int,
Producto varchar(100),
Cantidad int,
StockAnterior int,
StockActual int,
PrecioCompra numeric(8,2),
PrecioVenta numeric(8,2),
FechaRegistro varchar(10),
HoraRegistro varchar(8),
IdUsuario int,
Usuario varchar(100),
IdProveedor int,
Proveedor varchar(50),
DocVenta varchar(100),
FechaDocVenta varchar(10),
AnulaIdUsuario int,
AnulaUsuario varchar(30),
AnulaMotivo varchar(100),
AnulaFecha varchar(10),
AnulaHora varchar(8),
Estado char(1) check(Estado in('0','1')) not null,
foreign key(IdProducto) references Producto(IdProducto),
foreign key(IdProveedor) references Proveedor(IdProveedor)
)
go

------------------------------------------
Create Proc Registrar_Existencia
@IdCategoria int,
@Categoria varchar(30),
@Codbarra varchar(20),
@IdProducto int,
@Producto varchar(100),
@Cantidad int,
@StockAnterior int,
@StockActual int,
@PrecioCompra numeric(8,2),
@PrecioVenta numeric(8,2),
@FechaRegistro varchar(10),
@HoraRegistro varchar(8),
@IdUsuario int,
@Usuario varchar(30),
@IdProveedor int,
@Proveedor varchar(50),
@DocVenta varchar(100),
@FechaDocVenta varchar(10),
@AnulaIdUsuario int,
@AnulaUsuario varchar(30),
@AnulaMotivo varchar(100),
@AnulaFecha varchar(10),
@AnulaHora varchar(8),
@Estado char(1)
as begin	
	insert into Existencia values(@IdCategoria,@Categoria,@Codbarra,@IdProducto,@Producto,@Cantidad,@StockAnterior,@StockActual,@PrecioCompra,@PrecioVenta,@FechaRegistro,@HoraRegistro,@IdUsuario,@Usuario,@IdProveedor,@Proveedor,@DocVenta,@FechaDocVenta,@AnulaIdUsuario,@AnulaUsuario,@AnulaMotivo,@AnulaFecha,@AnulaHora,@Estado)
end 
go

------------------------------------------
Create Proc AnularActivar_Existencia
@IdExistencia int,
@AnulaIdUsuario int,
@AnulaUsuario varchar(30),
@AnulaMotivo varchar(100),
@AnulaFecha varchar(10),
@AnulaHora varchar(8),
@Estado char(1)
as begin	
	update Existencia set AnulaIdUsuario=@AnulaIdUsuario,AnulaUsuario=@AnulaUsuario,AnulaMotivo=@AnulaMotivo,AnulaFecha=@AnulaFecha,AnulaHora=@AnulaHora,Estado=@Estado
	where IdExistencia=@IdExistencia
end 
go

------------------------------------------
Create Proc Buscar_Existencia_Fecha
@FechaInicio varchar(10),
@FechaFinal varchar(10),
@Estado char(1),
@Parametro varchar(100)
as begin
 select * from Existencia
 where FechaRegistro>=@FechaInicio and FechaRegistro <= @FechaFinal and Estado=@Estado and (Categoria like '%'+@Parametro+'%' or Producto like '%'+@Parametro+'%' or Usuario like '%'+@Parametro+'%' or Codbarra like '%'+@Parametro+'%')
 order by FechaRegistro desc, HoraRegistro desc
 end
go


-- ==============================================
--                 TABLA VENTA
-- ==============================================

create table Venta
(IdVenta int identity(1,1) primary key,
FechaRegistro varchar(10),
HoraRegistro varchar(8),
IdUsuario int,
Usuario varchar(100),
IdCliente int,
Cliente varchar(100),
DocIdentidad varchar(20),
Direccion varchar(100),
DocVentaTipo varchar(100),
DocVentaNum varchar(100),
AnioMes varchar(10),
TotalsinImpuesto numeric(8,2),
Impuesto numeric(8,2),
TotalVenta numeric(8,2),
PagoEfectivo numeric(8,2),
CambioEfectivo numeric(8,2),
AnulaIdUsuario int,
AnulaUsuario varchar(30),
AnulaMotivo varchar(100),
AnulaFecha varchar(10),
AnulaHora varchar(8),
Estado char(1) check(Estado in('0','1')) not null,
foreign key(IdUsuario) references Usuario(IdUsuario),
foreign key(IdCliente) references Cliente(IdCliente)
)
go

------------------------------------------
Create Proc Registrar_Venta
@FechaRegistro varchar(10),
@HoraRegistro varchar(8),
@IdUsuario int,
@Usuario varchar(100),
@IdCliente int,
@Cliente varchar(100),
@DocIdentidad varchar(20),
@Direccion varchar(100),
@DocVentaTipo varchar(100),
@DocVentaNum varchar(100),
@AnioMes varchar(10),
@TotalsinImpuesto numeric(8,2),
@Impuesto numeric(8,2),
@TotalVenta numeric(8,2),
@PagoEfectivo numeric(8,2),
@CambioEfectivo numeric(8,2),
@Estado char(1),
@Token varchar(30)
as begin	
	insert into Venta values(@FechaRegistro,@HoraRegistro,@IdUsuario,@Token,@IdCliente,@Cliente,@DocIdentidad,@Direccion,@DocVentaTipo,@DocVentaNum,@AnioMes,@TotalsinImpuesto,@Impuesto,@TotalVenta,@PagoEfectivo,@CambioEfectivo,null,'','','','',@Estado);
	select IdVenta from Venta where Usuario=@Token;
	update Venta set Usuario=@Usuario where Usuario=@Token;
end 
go

------------------------------------------
Create Proc AnularActivar_Venta
@IdVenta int,
@AnulaIdUsuario int,
@AnulaUsuario varchar(30),
@AnulaMotivo varchar(100),
@AnulaFecha varchar(10),
@AnulaHora varchar(8),
@Estado char(1)
as begin	
	update Venta set AnulaIdUsuario=@AnulaIdUsuario,AnulaUsuario=@AnulaUsuario,AnulaMotivo=@AnulaMotivo,AnulaFecha=@AnulaFecha,AnulaHora=@AnulaHora,Estado=@Estado
	where IdVenta=@IdVenta
end 
go

------------------------------------------
Create Proc Buscar_Venta_Fecha
@FechaInicio varchar(10),
@FechaFinal varchar(10),
@Estado char(1),
@Parametro varchar(100)
as begin
 select * from Venta
 where FechaRegistro>=@FechaInicio and FechaRegistro <= @FechaFinal and Estado=@Estado 
 and (DocIdentidad like '%'+@Parametro+'%' or Usuario like '%'+@Parametro+'%' or Cliente like '%'+@Parametro+'%' or DocVentaNum like '%'+@Parametro+'%')
 order by FechaRegistro desc, HoraRegistro desc
 end
go

CREATE PROCEDURE Reporte_Venta  
@FechaInicio varchar(10),
@FechaFinal varchar(10),
@Estado char(1)
AS BEGIN
SELECT SUBSTRING(AnioMes,1,4) AS 'ANIO', SUBSTRING(AnioMes,6,2) AS 'MES', AnioMes,SUM(TotalVenta) AS 'TotalVenta' 
FROM Venta 
WHERE FechaRegistro>=@FechaInicio and FechaRegistro <= @FechaFinal and Estado=@Estado
GROUP BY AnioMes
ORDER BY AnioMes ASC
END
GO


-- ==============================================
--                 TABLA VENTA_DETALLE
-- ==============================================

create table VentaDetalle
(IdVentaDetalle int identity(1,1) primary key,
FechaRegistro varchar(10),
IdVenta int,
Item int,
Codbarra varchar(20),
IdProducto int,
Producto varchar(100),
Cantidad int,
Stock int,
PrecioCompra numeric(8,2),
PrecioVenta numeric(8,2),
Total numeric(8,2),
Estado char(1) check(Estado in('0','1')) not null,
foreign key(IdProducto) references Producto(IdProducto)
)
go

------------------------------------------
Create Proc Registrar_VentaDetalle
@FechaRegistro varchar(10),
@IdVenta int,
@Item int,
@Codbarra varchar(20),
@IdProducto int,
@Producto varchar(100),
@Cantidad int,
@Stock int,
@PrecioCompra numeric(8,2),
@PrecioVenta numeric(8,2),
@Total numeric(8,2),
@Estado char(1)
as begin	
	insert into VentaDetalle values(@FechaRegistro,@IdVenta,@Item,@Codbarra,@IdProducto,@Producto,@Cantidad,@Stock,@PrecioCompra,@PrecioVenta,@Total,@Estado)
end 
go

------------------------------------------
Create Proc AnularActivar_VentaDetalle_xIdVenta
@IdVenta int,
@Estado char(1)
as begin
	update VentaDetalle set Estado=@Estado
	where IdVenta=@IdVenta
end 
go

------------------------------------------
Create Proc Buscar_VentaDetalle_xIdVenta
@IdVenta int
as begin
 select * from VentaDetalle
 where IdVenta=@IdVenta
 order by Item asc
 end
go

------------------------------------------
Create Proc Buscar_VentaDetalle_Fecha
@FechaInicio varchar(10),
@FechaFinal varchar(10),
@Estado char(1)
as begin
 select * from VentaDetalle
 where FechaRegistro>=@FechaInicio and FechaRegistro <= @FechaFinal and Estado=@Estado 
 order by FechaRegistro asc
 end
go

-- ==============================================
-- ==============================================

CREATE PROCEDURE Imprimir_Venta
@IdVenta INT
AS BEGIN
SELECT 
       V.IdVenta AS 'V.IdVenta'
      ,V.FechaRegistro AS 'V.FechaRegistro'
      ,V.HoraRegistro AS 'V.HoraRegistro'
      ,V.IdUsuario AS 'V.IdUsuario'
      ,V.Usuario AS 'V.Usuario'
      ,V.IdCliente AS 'V.IdCliente'
      ,V.Cliente AS 'V.Cliente'
      ,V.DocIdentidad AS 'V.DocIdentidad'
      ,V.Direccion AS 'V.Direccion'
      ,V.DocVentaTipo AS 'V.DocVentaTipo'
      ,V.DocVentaNum AS 'V.DocVentaNum'
      ,V.AnioMes AS 'V.AnioMes'
      ,V.TotalsinImpuesto AS 'V.TotalsinImpuesto'
      ,V.Impuesto AS 'V.Impuesto'
      ,V.TotalVenta AS 'V.TotalVenta'
      ,V.PagoEfectivo AS 'V.PagoEfectivo'
      ,V.CambioEfectivo AS 'V.CambioEfectivo'
      ,V.AnulaIdUsuario AS 'V.AnulaIdUsuario'
      ,V.AnulaUsuario AS 'V.AnulaUsuario'
      ,V.AnulaMotivo AS 'V.AnulaMotivo'
      ,V.AnulaFecha AS 'V.AnulaFecha'
      ,V.AnulaHora AS 'V.AnulaHora'
      ,V.Estado AS 'V.Estado'
      ,VD.IdVentaDetalle AS 'VD.IdVentaDetalle'
      ,VD.FechaRegistro AS 'VD.FechaRegistro'
      ,VD.IdVenta AS 'VD.IdVenta'
      ,VD.Item AS 'VD.Item'
      ,VD.Codbarra AS 'VD.Codbarra'
      ,VD.IdProducto AS 'VD.IdProducto'
      ,VD.Producto AS 'VD.Producto'
      ,VD.Cantidad AS 'VD.Cantidad'
      ,VD.Stock AS 'VD.Stock'
      ,VD.PrecioCompra AS 'VD.PrecioCompra'
      ,VD.PrecioVenta AS 'VD.PrecioVenta'
      ,VD.Total AS 'VD.Total'
      ,VD.Estado AS 'VD.Estado'
  FROM Venta V inner join VentaDetalle VD ON V.IdVenta=VD.IdVenta
  WHERE V.IdVenta=@IdVenta
  ORDER BY VD.Item ASC
  END;
  GO


-- =================================================================
-- SP: Verificar referencias entre tablas para eliminación correcta
-- =================================================================

----------------- Area -----------------
Create Proc Area_con_referencia_en_Usuario
@IdArea int
as begin
 select count(*) as Total from Usuario where IdArea= @IdArea
 end
go
----------------- Usuario -----------------
Create Proc Usuario_con_referencia_en_Venta
@IdUsuario int
as begin
 select count(*) as Total from Venta where IdUsuario= @IdUsuario
 end
go
----------------- Cliente -----------------
Create Proc Cliente_con_referencia_en_Venta
@IdCliente int
as begin
 select count(*) as Total from Venta where IdCliente= @IdCliente
 end
go
----------------- Categoria -----------------
Create Proc Categoria_con_referencia_en_Producto
@IdCategoria int
as begin
 select count(*) as Total from Producto where IdCategoria= @IdCategoria
 end
go
----------------- UMedida -----------------
Create Proc UMedida_con_referencia_en_Producto
@IdUMedida int
as begin
 select count(*) as Total from Producto where IdUMedida= @IdUMedida
 end
go
----------------- Proveedor -----------------
Create Proc Proveedor_con_referencia_en_Existencia
@IdProveedor int
as begin
 select count(*) as Total from Existencia where IdProveedor= @IdProveedor
 end
go
----------------- Producto -----------------
Create Proc Producto_con_referencia_en_Existencia
@IdProducto int
as begin
 select count(*) as Total from Existencia where IdProducto= @IdProducto
 end
go

Create Proc Producto_con_referencia_en_VentaDetalle
@IdProducto int
as begin
 select count(*) as Total from VentaDetalle where IdProducto= @IdProducto
 end
go


-- ====================================================================
--                   Insertando datos de prueba
-- ====================================================================

----------------- Area -----------------
insert Area values('SISTEMAS','1')
insert Area values('ADMINISTRACION','1')
insert Area values('VENTAS','1')
insert Area values('COMPRAS','1')
insert Area values('ALMACEN','1')
go
----------------- Usuario -----------------
insert Usuario values('11114444','FOX','MEGAN','F',1,'AV. PROCERES 12345 - MIRAFLORES','9876543210','mail@xyz.net','MFOX','12345678','1')
insert Usuario values('11116666','WATSON','EMMA','F',2,'AV. TACNA 12345 - JESUS MARIA','9876543210','mail@xyz.net','EWATSON','12345678','1')
insert Usuario values('11115555','GWEN','STEFANI','F',2,'AV. LIMA 12345 - LA VICTORIA','9876543210','mail@xyz.net','SGWEN','12345678','1')
go
----------------- Permiso -----------------
insert Permiso values(1,1,1,1,1,1,1,1,1,1,1,1,1,1)
insert Permiso values(2,1,1,1,1,1,1,1,1,1,1,1,1,1)
insert Permiso values(3,1,1,1,1,1,1,1,1,1,1,1,1,1)
go

----------------- Cliente -----------------
insert Cliente values('','EVENTUAL','CLIENTE','M','-','','',1)
insert Cliente values('11117777','TODA','ERIKA','F','AV. AREQUIPA 12345 - SURCO','9876543210','mail@xyz.net','1')
insert Cliente values('11118888','GAUCHO','RONALDINHO','M','AV. TRUJILLO 12345 - SURQUILLO','9876543210','mail@xyz.net','1')
insert Cliente values('11119999','NAZARIO','RONALDO','M','AV. ICA 12345 - SURCO','9876543210','mail@xyz.net','1')
go

----------------- Categoria -----------------
insert Categoria values('COMESTIBLE','1')
insert Categoria values('TECLADO','1')
insert Categoria values('MOUSE','1')
go

----------------- UMedida -----------------
insert UMedida values('UNIDAD','UNID','1')
go

----------------- Proveedor -----------------
insert Proveedor values('00254507801','EMPRESA ABC S.A.','CAL. LOS NEGOCIOS NRO. 12345','123456789','1')
insert Proveedor values('00259496402','EMPRESA XYZ S.A.','PJ. LOS PINOS NRO. 12345','123456789','1')
insert Proveedor values('00212331303','EMPRESA DEF S.A.','CAL. RAUL REBAGLIATI NRO. 12345','123456789','1')
insert Proveedor values('00601429104','EMPRESA HGI S.R.L.','AV. DE LA FLORESTA NRO. 12345','123456789','1')

go

----------------- Producto -----------------
INSERT PRODUCTO VALUES(1,1,'AZUCAR MORENA BL X5KG','7750000000101',46,10,12,'1');
INSERT PRODUCTO VALUES(1,1,'ACEITE GIRASOL 900ML','7750000000102',35,3,5,'1');
INSERT PRODUCTO VALUES(1,1,'ACEITE SOYA 1L','7750000000103',44,4,6,'1');
INSERT PRODUCTO VALUES(1,1,'FIDEOS ABC BL 500GR','7750000000104',60,1,2,'1');
INSERT PRODUCTO VALUES(1,1,'QUINUA ABC BL 450GR','7750000000105',40,5,6,'1');
INSERT PRODUCTO VALUES(1,1,'FILETE ATUN ABC 170GR','7750000000106',55,4,5,'1');
INSERT PRODUCTO VALUES(1,1,'ACEITE OLIVA ABC 500G','7750000000107',30,15,18,'1');
INSERT PRODUCTO VALUES(1,1,'ENDULZANT ESTEVIA 50G','7750000000108',25,16,18,'1');
INSERT PRODUCTO VALUES(1,1,'MOSTAZA ABC 200GR','7750000000109',40,4,5,'1');
INSERT PRODUCTO VALUES(1,1,'HAMBURGUESA POLLO ABC','7750000000110',30,9,11,'1');
INSERT PRODUCTO VALUES(1,1,'INFUSION TE ABC CJ.25','7750000000111',60,2,3,'1');
INSERT PRODUCTO VALUES(1,1,'LECHE VACA ABC 1L','7750000000112',20,4,5,'1');
INSERT PRODUCTO VALUES(1,1,'CEREAL BARRA ABC PK8','7750000000113',40,3,4,'1');
INSERT PRODUCTO VALUES(1,1,'GALLETA SALADA ABC PK7','7750000000114',52,2,3,'1');
INSERT PRODUCTO VALUES(1,1,'YOGURT FRESA ABC 900ML','7750000000115',25,4,6,'1');
INSERT PRODUCTO VALUES(1,1,'MANTEQUILLA ABC 400G','7750000000116',30,10,12,'1');
INSERT PRODUCTO VALUES(1,1,'QUESO MOZARELLA 250G','7750000000117',45,8,10,'1');
INSERT PRODUCTO VALUES(1,1,'AGUA MINERAL ABC 1.5L','7750000000118',48,2,3,'1');
INSERT PRODUCTO VALUES(1,1,'CERVEZA ABC PK6 343ML','7750000000119',80,16,19,'1');
INSERT PRODUCTO VALUES(1,1,'WHISKY ABC 750ML','7750000000120',12,100,120,'1');
INSERT PRODUCTO VALUES(1,1,'VINO ABC SEMIDULCE 1L','7750000000121',50,10,15,'1');
INSERT PRODUCTO VALUES(1,1,'SHAMPOO ABC 400ML','7750000000122',40,12,15,'1');
INSERT PRODUCTO VALUES(1,1,'JABON DESINF PK3 110G','7750000000123',35,7,8,'1');
INSERT PRODUCTO VALUES(1,1,'CREMA DENTAL ABC PK3 75ML ','7750000000124',42,9,11,'1');
INSERT PRODUCTO VALUES(1,1,'PAPEL HIGIENICO ABC PK24','7750000000125',80,12,14,'1');
INSERT PRODUCTO VALUES(1,1,'DETERGENTE ABC 800G','7750000000126',65,5,7,'1');

insert Producto values(2,1,'TECLADO GENIUS KB-110X BLACK','7750000000013',20,22,25,'1')
insert Producto values(2,1,'TECLADO HP K1500 BLACK','7750000000014',20,20,24,'1')
insert Producto values(2,1,'TECLADO LOGITECH K120','7750000000015',20,28,35,'1')
insert Producto values(2,1,'TECLADO MICROSOFT DESKTOP-600','7750000000016',20,25,30,'1')
insert Producto values(3,1,'MOUSE GENIUS DX-110 USB NEGRO','7750000000017',90,15,20,'1')
insert Producto values(3,1,'MOUSE HP X900 USB BLACK','7750000000018',60,17,22,'1')
insert Producto values(3,1,'MOUSE LOGITECH M105 BLACK','7750000000019',70,16,20,'1')
insert Producto values(3,1,'MOUSE MICROSOFT BASIC NEGRO USB','7750000000020',50,25,35,'1')
GO

----------------- GenericTable -----------------
INSERT INTO GenericTable VALUES('VERSION',1,'V','Versión 0.01',1);
INSERT INTO GenericTable VALUES('SEXO',1,'M','MASCULINO',NULL);
INSERT INTO GenericTable VALUES('SEXO',2,'F','FEMENINO',NULL);
INSERT INTO GenericTable VALUES('MONEDA',1,'S/','SOLES PERUANOS',3);
INSERT INTO GenericTable VALUES('MONEDA',2,'$','DOLARES AMERICANOS',1);
INSERT INTO GenericTable VALUES('IMPUESTO',1,'I.G.V','IMPUESTO GENERAL A LAS VENTAS',18);
INSERT INTO GenericTable VALUES('FILTRO_DOC',1,'1','VIGENTES',NULL);
INSERT INTO GenericTable VALUES('FILTRO_DOC',2,'0','ANULADOS',NULL);

INSERT INTO GenericTable VALUES('TIPO_DOCUMENTO',1,'F','FACTURA',NULL);
INSERT INTO GenericTable VALUES('TIPO_DOCUMENTO',2,'B','BOLETA DE VENTA',NULL);
INSERT INTO GenericTable VALUES('TIPO_DOCUMENTO',3,'N','NOTA DE VENTA',NULL);
GO



