describe("My first test", () => {
  beforeEach(() => {
    // start or reset phoenix
    cy.exec(
      '(cd .. && ( \
        iex --sname phx -S mix phx.server || \
        iex --sname reset <<< ":rpc.call(:phx@$(uname -n), :init, :restart, [])" \
        ) & \
        ) && \
        sleep 12 && \
        npx wait-on -t 20  tcp:4000'
    );
  });

  it("Visit login page", () => {
    cy.visit("/");
    cy.get("input#credentials_name").type("hello");
    cy.get("input#credentials_password").type("hello");
    cy.get("button[class='button is-danger']").click();

    cy.visit("/");
    cy.get("input#credentials_name").type("tom");
    cy.get("input#credentials_password").type("tom");
    cy.get("button[class='button is-danger']").click();

    cy.get("input[type='input']").type("first msg{enter}");
    cy.get("input[type='input']").type("second msg{enter}");

    cy.visit("/hello");
    cy.get("input[type='input']").type("first msg{enter}");
    cy.get("input[type='input']").type("second msg{enter}");

    cy.get("ul.messages_list > li").should(($lis) => {
      expect($lis).to.have.length(4);
      expect($lis.eq(0)).to.contain("tom: first msg");
      expect($lis.eq(1)).to.contain("tom: second msg");
      expect($lis.eq(2)).to.contain("hello: first msg");
      expect($lis.eq(3)).to.contain("hello: second msg");
    });
  });
});
