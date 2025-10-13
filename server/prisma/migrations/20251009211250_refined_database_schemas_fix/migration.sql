/*
  Warnings:

  - You are about to drop the column `addresseeId` on the `ConnectionRequest` table. All the data in the column will be lost.
  - You are about to drop the column `aId` on the `Connections` table. All the data in the column will be lost.
  - You are about to drop the column `bId` on the `Connections` table. All the data in the column will be lost.
  - Added the required column `requestedId` to the `ConnectionRequest` table without a default value. This is not possible if the table is not empty.
  - Added the required column `requestedId` to the `Connections` table without a default value. This is not possible if the table is not empty.
  - Added the required column `requesterId` to the `Connections` table without a default value. This is not possible if the table is not empty.

*/
-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_ConnectionRequest" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "requesterId" TEXT NOT NULL,
    "requestedId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" DATETIME,
    CONSTRAINT "ConnectionRequest_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ConnectionRequest_requestedId_fkey" FOREIGN KEY ("requestedId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_ConnectionRequest" ("createdAt", "decidedAt", "id", "requesterId", "status", "type") SELECT "createdAt", "decidedAt", "id", "requesterId", "status", "type" FROM "ConnectionRequest";
DROP TABLE "ConnectionRequest";
ALTER TABLE "new_ConnectionRequest" RENAME TO "ConnectionRequest";
CREATE INDEX "ConnectionRequest_requesterId_requestedId_type_status_idx" ON "ConnectionRequest"("requesterId", "requestedId", "type", "status");
CREATE TABLE "new_Connections" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "requesterId" TEXT NOT NULL,
    "requestedId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "since" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Connections_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Connections_requestedId_fkey" FOREIGN KEY ("requestedId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "new_Connections" ("id", "since", "type") SELECT "id", "since", "type" FROM "Connections";
DROP TABLE "Connections";
ALTER TABLE "new_Connections" RENAME TO "Connections";
CREATE UNIQUE INDEX "Connections_requesterId_requestedId_type_key" ON "Connections"("requesterId", "requestedId", "type");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
