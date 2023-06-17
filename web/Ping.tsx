import { useAccount, useApi, useAlert } from "@gear-js/react-hooks";
import { web3FromSource } from "@polkadot/extension-dapp";
import { getProgramMetadata } from "@gear-js/api";
import { Button } from "@gear-js/ui";

function Ping() {
  const alert = useAlert();
  const { accounts, account } = useAccount();
  const { api } = useApi();

  // Add your programID
  const programID =
    "0xa7a78d50da854265ec316c1cb259f45650ffdc2e7832f46c994a4d69579b5450";

  // Add your metadata.txt
  const meta =
    "000001000000000100000000000000000001010000003408000000050200040000020000";

  const metadata = getProgramMetadata(`0x${meta}`);

  const messageinit = "PING";
 
  const message: any = {
    destination: programID, // programId
    payload: messageinit,
    gasLimit: 899819245,
    value: 0,
  };

  const signer = async () => {
    const localaccount = account?.address;
    const isVisibleAccount = accounts.some(
      (visibleAccount) => visibleAccount.address === localaccount
    );

    if (isVisibleAccount) {
      // Create a message extrinsic
      const extrinsic = api.message.send(message, metadata);

      const injector = await web3FromSource(accounts[0].meta.source);

      extrinsic
        .signAndSend(
          accounts[0].address,
          { signer: injector.signer },
          ({ status }) => {
            if (status.isInBlock) {
              console.log(
                `Completed at block hash #${status.asInBlock.toString()}`
              );
              alert.success(`Block hash #${status.asInBlock.toString()}`);
            } else {
              console.log(`Current status: ${status.type}`);
              if (status.type === "Finalized") {
                alert.success(status.type);
              }
            }
          }
        )
        .catch((error: any) => {
          console.log(":( transaction failed", error);
        });
    } else {
      alert.error("Account not available to sign");
    }

    // Usermessagesent subscription
    const unsub = api.gearEvents.subscribeToGearEvent(
      "UserMessageSent",
      ({
        data: {
          message: { id, source, destination, payload, value },
        },
      }) => {
        console.log(`
      messageId: ${id.toHex()}
      source: ${source.toHex()}
      payload: ${payload.toHuman()}
      `);
      }
    );
  };

  return <Button text="Ping" onClick={signer} />;
}

export { Ping };
