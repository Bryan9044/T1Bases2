use AdventureWorks2022
go


-- Primer procedimiento almacenado el cuál nos provee una lista de todas las personas involucradas en las tiendas.
create procedure selectClientes
as
begin
	select BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, Suffix ,EmailPromotion
      ,AdditionalContactInfo
      ,Demographics
      ,rowguid
      ,ModifiedDate
	from Person.Person
end;





-- Segundo procedimiento almacenado este lo que hace es crear un BusinessEntity para una persona, de esta forma 
-- Logramos asignar una persona de forma correcta sino se crea el BusinessEntity no sera posible

go
create procedure insertClientes
    @TipoPersona VARCHAR(2),
    @Nombre VARCHAR(30),
    @SegundoNombre VARCHAR(30) = null, 
    @Apellido VARCHAR(30)
as
begin
    set nocount on;

    declare @NuevoID int;

        insert into Person.BusinessEntity default values;
        set @NuevoID = scope_identity();

        insert into Person.Person (
            BusinessEntityID,
            PersonType,
            NameStyle,
            FirstName,
            MiddleName,
            LastName,
            EmailPromotion,
            rowguid,
            ModifiedDate
        )
        values (
            @NuevoID,
            @TipoPersona,
            0,
            @Nombre,
            @SegundoNombre,
            @Apellido,
            0,
            newid(),
            getdate()
        );

        select @NuevoID as BusinessEntityID;

end;
go




-- tercer procedimiento almacenado este consiste en un insert para la tabla de tiendas pero para poder crearlo
-- es necesario que creemos un BusinessEntity por eso de igual forma que el anterior se hace con valores
-- predeterminados pues lo que se busca es solo utilizar el ID
go
create procedure insertTiendas
    @NombreTienda varchar(50),
    @IdVendedor int
as
begin
    set nocount on;

    declare @idTienda int;

    insert into Person.BusinessEntity default values;
    set @idTienda = scope_identity();

    insert into Sales.Store (
        BusinessEntityID,
        Name,
        SalesPersonID,
        rowguid,
        ModifiedDate
    ) values (
        @idTienda,
        @NombreTienda,
        @IdVendedor,
        newid(),
        getdate()
    );

    select @idTienda as BusinessEntityID;
end;






-- Cuarto procedimiento almacenado que solo busca eliminar información acerca de un trabajador para su correo y celular
-- esto lo hacemos por medio de ciertos valores con los cuales buscaremos el id de BusinessEntity para poder lograr el borrado correcto de la persona
go
create procedure eliminarCelularCorreoP 
    @PersonType varchar(2),
    @FirstName varchar(15),
    @MiddleName varchar(15) = NULL,
    @LastName varchar(15)
as
begin
    declare @BusinessEntityID int;

    select @BusinessEntityID = BusinessEntityID
    from Person.Person
    where PersonType = @PersonType
      and FirstName = @FirstName
	 and LastName = @LastName
      and (
            (@MiddleName is null and MiddleName is null)
            or (@MiddleName is not null and MiddleName = @MiddleName)
          );


    if @BusinessEntityID is not null
    begin
        delete from Person.EmailAddress
        where BusinessEntityID = @BusinessEntityID;

		delete from Person.PersonPhone
		where BusinessEntityID = @BusinessEntityID
        print 'Persona eliminada correctamente.';
    end
    else
    begin
        print 'No se encontró ninguna persona con esos datos.';
    end
end;





-- Este es el quinto procedimiento almacenado y consta de una actualización al nombre de la tienda que el usuario desee
-- Para poder generar la edición solo necesitamos el nombre original de la tienda y el nuevo nombre que deseamos asignar 
go 
create procedure actualizarNombreTienda
    @NombreTienda varchar(50),
    @NuevoNombre varchar(50)
as
begin
    set nocount on;

    declare @IdTienda int;

    select @IdTienda = BusinessEntityID
    from Sales.Store
    where Name = @NombreTienda;

    update Sales.Store
    set Name = @NuevoNombre
    where BusinessEntityID = @IdTienda;

    select @IdTienda AS BusinessEntityID;
end;



-- Sexto procedimiento almacenado el cual consta de un select que trae todas las tablas de tiendas para mostrar
go
create procedure verTiendas
as
begin 
	select BusinessEntityID, Name, SalesPersonID, Demographics, rowguid, ModifiedDate 
	from Sales.Store
end;
go


-- Septimo procedimiento almacenado el cual consta de un select que trae todas las tablas de los trabajadores para mostrar
create procedure verTrabajadores
as
begin
	select pp.BusinessEntityID, pp.PersonType, pp.NameStyle, pp.Title, pp.FirstName, pp.MiddleName, pp.LastName, pp.Suffix, pp.EmailPromotion
      ,pp.AdditionalContactInfo, pp.Demographics, pp.rowguid, pp.ModifiedDate
	from Person.Person pp
	join Sales.Customer sc on pp.BusinessEntityID = sc.PersonID
end;



-- Octavo procedimiento almacenado el cual consta de un select que por medio de filtros nos trae los trabajadores  
-- registrados en recursos humanos que cumplan las condiciones puestas por el usuario
go
create procedure TrabajadoresFiltroSexo
	@genero varchar(1),
	@estadoMarital varchar(1)
as
begin
	select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, JobTitle
      ,BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid, ModifiedDate
	from HumanResources.Employee
	where Gender = @genero and MaritalStatus = @estadoMarital
end;



