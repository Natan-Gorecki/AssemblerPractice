#include "Python.h"

/**
* print_python_bytes - prints info about a Python 3 bytes object
* @p: a pointer to a Python 3 bytes object
*
* Return: Nothing
*/
void print_python_bytes(PyObject *p)
{
    // The pointer with the correct type
    PyBytesObject *s;

    printf("[.] bytes object info\n");
    
    // casting the PyObject pointer to a PyBytesObject pointer
    s = (PyBytesObject*)p;

    // never trust anyone, check that this is actually a PyBytesPointer object
    if(s && PyBytes_Check(s)) 
    {
        // a pointer holds the memory address of the first byte of the data it points to
        printf("\taddress of the object: %p\n", (void*)s);

        // op_size is in the ob_base structure, of type PyVarObject
        printf("\tsize: %d\n", s->ob_base.ob_size);

        // ob_sval is the array of the bytes, ending with the value 0: ob_sval[ob_size] == 0
        printf("\ttrying string: %s\n", s->ob_sval);
        printf("\taddress of the data: %p\n", (void*)(s->ob_sval));
        printf("\tbytes:\n");
        
        // printing each byte at a time, in case this is not a "string" - bytes doesn't have to be strings
        // ob_sval contains space for 'ob_size+1' elements
        for(int i=0; i < s->ob_base.ob_size+1; i++) 
        {
            printf("\t%02x", s->ob_sval[i] & 0xff);
        }
        printf("\n");
    }

    // if this is not a PyBytesObject print an error message
    else 
    {
        fprintf(stderr, "\t[ERROR] Invalid Bytes Object\n");
    }
}

// gcc -Wall -Wextra -pedantic -Werror -std=c99 -shared -Wl,-soname,libCheckPythonBytes.so -o libCheckPythonBytes.so -fPIC -I/usr/include/python3.9 0002_bytes.c