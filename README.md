## Tarea 3

### Logros de la entrega:
Clemente trabajo en los modelos y en comenzar los requests.
Aníbal Trabajo en el setup, github actions y completar los requests.

### Informacion para el correcto:
Corriendo con simple coverage, el html entrega 100% en modelos y casi todos los requests.

Para products_controller, se testea el camino en que el current_user no es admin para los metodos actualizar_producto y eliminar, en ests caso no se llega al else "Debes ser un administrador para modificar un producto." sino que hacer el request entrega "No estás autorizado para acceder a esta página". Esta es la ruta que se testea.