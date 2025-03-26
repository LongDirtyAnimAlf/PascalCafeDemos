This repo contains a mORMot demo for FPC and Lazarus.  
It is meant to be used for a short demonstration during the Lazarus meeting on March 29th 2025.  
The goal is to show the use of RDO and DTO to enhance the abstraction and re-use of code.  
RDO = Rich Data Object.  
DTO = Data Transfer Object.  
The application is based on the use of plain TCollections as RDO.  
The data from these RDO are persisted in a database through compatible DTO.  
The persistence layer is based on the use of plain TORM as DTO.  

https://wiki.freepascal.org/TCollection

In theory, the application should have no dependency on a database. Not visual, nor logical.  
The only dependency comes from the RDO <-> DTO coupling.  

I hope to be able to explain this in short detail during my presentation at the Lazarus meeting.
