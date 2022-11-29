// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Ecommerce{
    struct Product{
      string title;
      string desc;
      address payable seller;
      uint productId;
      uint price;
      address buyer;
      bool delivered;
    }

    uint counter=1;
    Product[] public products;
    address payable public manager;

    bool destroyed=false;

    modifier isNotDestroyed{
      require(!destroyed,"contract does not exist");
      _;
    }

    constructor(){
      manager=payable(msg.sender);
    }

    event registered(string title,uint productId,address seller);
    event bought(uint productId,address buyer);
    event deliver(uint productId);

    function registerProducts(string memory _title,string memory _desc,uint _price) public isNotDestroyed{
      require(_price>0,"Price should be positive");
      Product memory addedProduct;
      addedProduct.title=_title;
      addedProduct.desc=_desc;
      addedProduct.price=_price * 10**18;
      addedProduct.seller=payable(msg.sender);
      addedProduct.productId=counter;
      products.push(addedProduct);
      counter++;
      emit registered(_title,addedProduct.productId,msg.sender);
    }
    function buy(uint _productId) payable public isNotDestroyed{
      require(products[_productId-1].price==msg.value,"Please pay the exact price");
      require(products[_productId-1].seller!=msg.sender,"Seller cannot be the buyer");
      products[_productId-1].buyer=msg.sender;
      emit bought(_productId,msg.sender);
    }
    function delivery(uint _productId) public isNotDestroyed{
      require(products[_productId-1].buyer==msg.sender,"Only buyer can confirm");
      products[_productId-1].delivered=true;
      products[_productId-1].seller.transfer(products[_productId-1].price);
      emit deliver(_productId);
    }
    // function destroy() public {
    //   require(msg.sender==manager);
    //   selfdestruct(manager);
    // }

    function destroy() public isNotDestroyed{
      require(msg.sender==manager);
      manager.transfer(address(this).balance);
      destroyed=true;
    }

    fallback() payable external{
      payable(msg.sender).transfer(msg.value);
    }
}
        

