/*
  Warnings:

  - A unique constraint covering the columns `[adminId,name]` on the table `Groups` will be added. If there are existing duplicate values, this will fail.

*/
-- DropIndex
DROP INDEX "Groups_name_key";

-- CreateIndex
CREATE UNIQUE INDEX "Groups_adminId_name_key" ON "Groups"("adminId", "name");
