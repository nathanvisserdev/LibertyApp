/*
  Warnings:

  - You are about to drop the `Acquaintances` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `AcquaintanceshipRequest` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropIndex
DROP INDEX "Acquaintances_aId_bId_key";

-- DropIndex
DROP INDEX "AcquaintanceshipRequest_requesterId_addresseeId_key";

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "Acquaintances";
PRAGMA foreign_keys=on;

-- DropTable
PRAGMA foreign_keys=off;
DROP TABLE "AcquaintanceshipRequest";
PRAGMA foreign_keys=on;

-- CreateTable
CREATE TABLE "ConnectionRequest" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "requesterId" TEXT NOT NULL,
    "addresseeId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" DATETIME,
    CONSTRAINT "ConnectionRequest_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ConnectionRequest_addresseeId_fkey" FOREIGN KEY ("addresseeId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Connections" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "aId" TEXT NOT NULL,
    "bId" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "since" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Connections_aId_fkey" FOREIGN KEY ("aId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Connections_bId_fkey" FOREIGN KEY ("bId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "FollowRequest" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "followerId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "decidedAt" DATETIME,
    CONSTRAINT "FollowRequest_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "FollowRequest_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Follows" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "followerId" TEXT NOT NULL,
    "creatorId" TEXT NOT NULL,
    "since" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Follows_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Follows_creatorId_fkey" FOREIGN KEY ("creatorId") REFERENCES "Users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Users" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "firstName" TEXT,
    "lastName" TEXT,
    "username" TEXT,
    "dateOfBirth" DATETIME,
    "gender" BOOLEAN,
    "phoneNumber" TEXT,
    "zipCode" TEXT,
    "photo" TEXT,
    "about" TEXT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "isCreator" BOOLEAN NOT NULL DEFAULT false,
    "autoAcceptFollows" BOOLEAN NOT NULL DEFAULT false
);
INSERT INTO "new_Users" ("about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode") SELECT "about", "createdAt", "dateOfBirth", "email", "firstName", "gender", "id", "lastName", "password", "phoneNumber", "photo", "username", "zipCode" FROM "Users";
DROP TABLE "Users";
ALTER TABLE "new_Users" RENAME TO "Users";
CREATE UNIQUE INDEX "Users_email_key" ON "Users"("email");
CREATE UNIQUE INDEX "Users_username_key" ON "Users"("username");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE UNIQUE INDEX "ConnectionRequest_requesterId_addresseeId_kind_status_key" ON "ConnectionRequest"("requesterId", "addresseeId", "kind", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Connections_aId_bId_key" ON "Connections"("aId", "bId");

-- CreateIndex
CREATE UNIQUE INDEX "FollowRequest_followerId_creatorId_status_key" ON "FollowRequest"("followerId", "creatorId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Follows_followerId_creatorId_key" ON "Follows"("followerId", "creatorId");
