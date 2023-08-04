//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "forge-std/console.sol";

contract PetPark is Ownable {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        NotYetDefined,
        Female,
        Male
    }

    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => AnimalType) public borrowedAnimals;
    mapping(address => uint256) public ages;
    mapping(address => Gender) public genders;

    event Added(AnimalType animalType, uint256 count);
    event Returned(AnimalType animalType);
    event Borrowed(AnimalType animalType);

    modifier canGiveBackAnimal() {
       require(uint(borrowedAnimals[msg.sender]) > 0, "No borrowed pets");
        _;
    }

    modifier cantAddNone(AnimalType _animalType) {
        require(uint256(_animalType) > 0, "Invalid animal");
        _;
    }

    modifier ageZero(uint256 _age) {
        require(_age > 0, "Cant borrow at age 0");
        _;
    }

    /// @notice Adds an animal count to the shelter capacity
    /// @param _animalType The type of animal being added
    /// @param _count The amount of animals being made available
    function add(AnimalType _animalType, uint256 _count)
      public
      onlyOwner
      cantAddNone(_animalType)
    {
        animalCounts[AnimalType(_animalType)] += _count;
        emit Added(AnimalType(_animalType), _count);
    }

    /// @notice Borrows an animal from the shelter
    /// @param _age The age of the user borrowing the animal
    /// @param _gender The gender of the user borrowing the animal
    /// @param _animalType The type of animal being borrowed
    function borrow(uint256 _age, Gender _gender, AnimalType _animalType)
      public
      ageZero(_age)
    {
        if (ages[msg.sender] != 0) {
            require(ages[msg.sender] == _age, "Invalid Age");
        } else {
            ages[msg.sender] = _age;
        }

        if (uint256(genders[msg.sender]) != 0) {
            require(genders[msg.sender] == _gender, "Invalid Gender");
        } else {
            genders[msg.sender] = _gender;
        }

        require(uint(borrowedAnimals[msg.sender]) == 0, "Already adopted a pet");

        if (_animalType == AnimalType.None) {
            revert("Invalid animal type");
        } else if (_gender == Gender.Male) {
            require(_animalType == AnimalType.Dog || _animalType == AnimalType.Fish, "Invalid animal for men");
        } else if (_gender == Gender.Female && _animalType == AnimalType.Cat) {
            require(_age > 40, "Invalid animal for women under 40");
        }

        require(animalCounts[AnimalType(_animalType)] > 0, "Selected animal not available");

        animalCounts[AnimalType(_animalType)] -= 1;
        borrowedAnimals[msg.sender] = AnimalType(_animalType);
        emit Borrowed(AnimalType(_animalType));
    }

    /// @notice Gives back an animal to the shelter
    function giveBackAnimal()
      public
      canGiveBackAnimal
    {
        AnimalType borrowedAnimal = borrowedAnimals[msg.sender];
        borrowedAnimals[msg.sender] = AnimalType.None;
        animalCounts[borrowedAnimal] += 1;
        emit Returned(AnimalType(borrowedAnimal));
    }
}
