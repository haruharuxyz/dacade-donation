import Identicon from "identicon.js";
import React, { useEffect } from "react";
import { useData } from "../../contexts/DataContext";

function Header() {
  const { account } = useData();
  const [data, setData] = React.useState();
  useEffect(() => {
    if (account !== "0x0") {
      setData(new Identicon(account, 200).toString());
    }
  }, [account]);

  const formatAccount = (account) => {
    return account.slice(0, 5) + '...' + account.slice(-5);
  }
  return (
    <div className="container items-center">
      <div className="flex flex-col md:flex-row items-center md:justify-between border py-3 px-5 rounded-xl">
        <span className="font-mono">Celo Network</span>
        <div className="flex flex-row space-x-2 items-center">
          <div className="h-5 w-5 rounded-full bg-blue-500"></div>
          <span className="font-mono text-xl font-bold">Dacade Images Donation</span>
        </div>
        <div className="flex flex-row space-x-2 items-center">
          <span className="font-mono overflow-ellipsis w-52 overflow-hidden">
            {formatAccount(account)}
          </span>
          {account && data && (
            <img
              width={35}
              height={35}
              src={`data:image/png;base64, ${data}`}
            />
          )}
        </div>
      </div>
    </div>
  );
}

export default Header;
